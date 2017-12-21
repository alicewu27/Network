//
//  ViewController.swift
//  Network
//
//  Created by huayuan wu on 8/21/17.
//  Copyright © 2017 huayuan wu. All rights reserved.
//


// TODO: Language
//       Pop-out window
//       Help



import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var board: Checkerboard! {
       didSet {            
            let handler = #selector(self.makeMove(byReactingTo:))
            let recogonizer = UITapGestureRecognizer(target: self, action: handler)
            board.addGestureRecognizer(recogonizer)
        }
    }
    @IBOutlet weak var state: UITextField!
    
    var side = false
    var color : [Bool: UIColor] = [true: UIColor.white, false: UIColor.black]
    var pause = false
    
    @IBAction func modeControl(_ sender: UISwitch) {
        if sender.isOn {
            twoPlayerMode = true
        } else {
            twoPlayerMode = false
        }
    }
    var twoPlayerMode = false
    
    var brain = MachinePlayer(searchDepth: 8)
    var moveIsPending = false
    var pendingMove = Move(to_x: 0, to_y: 0, from_x: 0, from_y: 0)
    
    func makeMove(byReactingTo tapRecognizer: UITapGestureRecognizer) {
        if pause {
            return
        }
        
        if tapRecognizer.state == .ended {
            let location = tapRecognizer.location(in: board)
            if let (x,y) = board.getCordinateInBoard(tapPosition: location) {
                var successful = false
                //let index = brain.coordinateToIndex(x: x, y: y)
                if board.hasChip(x: x, y: y) {
                    if moveIsPending {                                    //no duplicate select chip
                        board.setSelectedChip(x: pendingMove.x2, y: pendingMove.y2, selected: false)
                        moveIsPending = false
                        state.text = "Illegal Move!"
                        return
                    } else {
                        moveIsPending = true
                        board.setSelectedChip(x: x, y: y, selected: true)
                        pendingMove.x2 = x
                        pendingMove.y2 = y
                    }
                } else {
                    if moveIsPending {                            //step move
                        pendingMove.x1 = x
                        pendingMove.y1 = y
                        if self.side {
                            successful = brain.forceMove(move: pendingMove)
                        } else {
                            successful = brain.opponentMove(move: pendingMove)
                        }                        
                        //print("human try move: " + m.toString())
                        if successful {
                            // print("human move successful: " + m.toString())
                            updateDueToMove(move: pendingMove, color:  side)
                            state.text = "Your move ..."
                        } else {
                            board.setSelectedChip(x: pendingMove.x2, y: pendingMove.y2, selected: false)
                            state.text = "Illegal Move!"
                        }
                        moveIsPending = false
                    } else {                            //add move
                        let m = Move(x: x, y: y)
                        if self.side {
                            successful = brain.forceMove(move: m)
                        } else {
                            successful = brain.opponentMove(move: m)
                        }

                        //print("human try move: " + m.toString())
                        if successful{
                            // print("human move successful: " + m.toString())
                            updateDueToMove(move: m, color: side)
                        }
                    }
                    if let (winSide, network) = brain.networkPath() {
                        //print(network)
                        state.text = "\(winSide) win!"
                        board.networkPath = network
                        pause = true
                        return
                    }
                    if twoPlayerMode && successful {
                        side = !side
                    }
                    
                }
                if successful && !twoPlayerMode {
                    let myMove = brain.chooseMove()
                    // print("Machine move: " + myMove.toString())
                    self.updateDueToMove(move: myMove, color: true)
                    /*if let path = brain.networkPath() {
                     board.networkPath = path
                     }*/
                    if let (winSide, network) = brain.networkPath() {
                        //print(network)
                        state.text = "\(winSide) win!"
                        board.networkPath = network
                        pause = true
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func restart(_ sender: UIButton) {
        brain.restart()
        board.restart()
        state.text = "New Game! Enjoy!"
        pause = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateDueToMove(move m: Move, color c: Bool) {
        if (m.moveKind == .ADD) {
            board.addChip(color: color[c]!, x: m.x1, y: m.y1)
        } else if (m.moveKind == .STEP) {
            board.moveChip(to_x: m.x1, to_y: m.y1, from_x: m.x2, from_y: m.y2)
        }
    }

}

