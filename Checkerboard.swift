//
//  Checkboard.swift
//  Network
//
//  Created by huayuan wu on 8/22/17.
//  Copyright © 2017 huayuan wu. All rights reserved.
//

import UIKit

class Checkerboard: UIView {
    let boardSize = 8
    //let lineColor = UIColor.black
    //let lineWidth : CGFloat = 3.0
    let blankGrid = UIColor.brown
    let scale : CGFloat = 0.9
    var networkPath : [(Int, Int)]? {
        didSet{
            setNeedsDisplay()
        }
    }
    var offset : CGFloat {
        return gridSize * 0.1
    }
    let pathColor = UIColor.red
    
    var gridSize : CGFloat {
        return min(bounds.size.width, bounds.size.height) / CGFloat(boardSize) * scale
    }
    
    private var boardOrigin : CGPoint {
        let halfBoardLength = gridSize * CGFloat(boardSize) / 2
        return CGPoint(x:  bounds.midX - halfBoardLength, y: bounds.midY - halfBoardLength)
    }
    
    private var gridXs : [CGFloat] {
        var grids = [CGFloat]()
        for i in 0...boardSize {
            grids.append(boardOrigin.x + CGFloat(i) * gridSize)
        }
        return grids
    }
    
    private var gridYs : [CGFloat] {
        var grids = [CGFloat]()
        for i in 0...boardSize {
            grids.append(boardOrigin.y + CGFloat(i) * gridSize)
        }
        return grids
    }
    
    private var innerLines : [UIBezierPath] {
        var lines = [UIBezierPath]()
        for i in 0...boardSize {
            lines.append(UIBezierPath())
            lines[i].move(to: CGPoint(x: gridXs[i], y: boardOrigin.y))
            lines[i].addLine(to: CGPoint(x: gridXs[i], y: boardOrigin.y + CGFloat(boardSize) * gridSize))
        }
        for i in 0...boardSize {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: boardOrigin.x, y: gridYs[i]))
            path.addLine(to: CGPoint(x: boardOrigin.x + CGFloat(boardSize) * gridSize, y: gridYs[i]))
            lines.append(path)
        }
        return lines
    }

    var boardFrame : UIBezierPath {
        return UIBezierPath(rect: CGRect(x: boardOrigin.x, y: boardOrigin.y, width: gridSize * 8, height: gridSize * 8))
    }
        
    func getCordinateInBoard(tapPosition location: CGPoint) -> (Int, Int)? {
       
        var x = -1
        var y = -1
        if location.x > gridXs.last! || location.x < gridXs.first!
            || location.y > gridYs.last! || location.y < gridYs.first! {  //tap out of bounds
            return nil
        }
        
        for i in 1 ... boardSize {
            if location.x <= gridXs[i] && location.x > gridXs[i-1]{
                y = i-1
            }
        }
        for j in 1 ... boardSize {
            if location.y <= gridYs[j] && location.y > gridYs[j-1]{
                x = j-1
            }
        }
        return (x,y)
    }
    
    private func coordinateToLocation(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: gridXs[y], y: gridYs[x])
    }
    
    private func coordinateToLocationCenter(x: Int, y: Int) -> CGPoint {
        return CGPoint(x: gridXs[y] + gridSize/2, y: gridYs[x] + gridSize/2)
    }
    
    func network() -> UIBezierPath? {
        if networkPath != nil {
            let p = UIBezierPath()
            let (x0, y0) = networkPath![0]
            p.move(to: coordinateToLocationCenter(x: x0, y: y0))
            for i in 1 ..< networkPath!.count {
                let (x, y) = networkPath![i]
                let loc = coordinateToLocationCenter(x: x, y: y)
                p.addLine(to: loc)
                p.move(to: loc)
            }
            return p
        } else {
            return nil
        }
        
    }
    func addChip(color: UIColor, x: Int, y: Int) {
        let location = coordinateToLocation(x: x, y: y)
        let newChipViewRect : CGRect = CGRect(x: location.x + offset, y: location.y + offset, width: gridSize - 2 * offset, height: gridSize - 2 * offset)
        let myView : Chip = Chip(frame: newChipViewRect)
        myView.color = color
        myView.tag = getChipViewTag(x: x, y: y)
        self.addSubview(myView)
        //self.setNeedsDisplay()
    }
    
    func moveChip(to_x x1:Int, to_y y1:Int, from_x x2:Int, from_y y2: Int) {
        if let chipView = viewWithTag(getChipViewTag(x: x2, y: y2)) as? Chip {
            let location = coordinateToLocation(x: x1, y: y1)
            chipView.center = CGPoint(x: location.x + gridSize / 2, y: location.y + gridSize / 2)
            chipView.tag = getChipViewTag(x: x1, y: y1)
            setSelectedChip(x: x1, y: y1, selected: false)

        }
                //chipView?.setNeedsDisplay()
    }
    
    private func getChipViewTag(x: Int, y: Int) -> Int {
        return x * boardSize + y
    }
    
    func hasChip(x: Int, y: Int) -> Bool {
        if viewWithTag(getChipViewTag(x: x, y: y)) != nil {
            return true
        }
        return false
    }
    
    func setSelectedChip(x: Int, y: Int, selected: Bool) {
        if let chip = viewWithTag(getChipViewTag(x: x, y: y)) as? Chip {
            if !selected {
                chip.selected = false
            } else {
                chip.selected = true
            }

        }
                //chip?.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        autoresizesSubviews = true
        let path : UIBezierPath = boardFrame
        
        path.stroke()
        blankGrid.setFill()
        path.fill()
        for line in innerLines {
            //line.lineWidth = lineWidth
            line.stroke()
        }
        if let np = network() {
           // np.lineWidth = lineWidth
            pathColor.setStroke()
            np.stroke()
        }
    }
    
    func restart() {
        let totalGrids = boardSize * boardSize
        for i in 1 ..< totalGrids {
            if let chip = viewWithTag(i) {
                chip.removeFromSuperview()            // viewWithTag still Exist ?????
            }
        }
        networkPath = nil
        self.setNeedsDisplay()
    }
 
}
