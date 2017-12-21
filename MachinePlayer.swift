//
//  NetworkBrain.swift
//  Network
//
//  Created by huayuan wu on 8/23/17.
//  Copyright © 2017 huayuan wu. All rights reserved.
//

import Foundation

struct MachinePlayer {
    let size = 8
    let gridsNumber = 64
    let chipsNumber = 10
    let minNetworkSize = 6
    private var path : [Int]
    private var numOfChips : [Color: Int]
    var color : [Bool: Color]
    //var color : Color = .white
    var board : [Color?]
    var searchDepth = 7
    private var moveNumber = 0
    
    enum Direction{
        case horizontal
        case vertical
        case mainDiag
        case antiDiag
        case other
    }
    
    init(searchDepth depth: Int) {
        board = Array(repeating: nil, count: gridsNumber)
        numOfChips = [.white: 0, .black: 0]
        path = [Int]()
        searchDepth = depth
        color = [true: .white, false: .black]
            /*
        board[1] = .black
        board[10] = .white
        
        board[12] = .black

        board[14] = .white

        board[16] = .white
        board[17] = .black
        
        board[26] = .black
        board[36] = .black
        board[37] = .black
        board[43] = .white
        board[46] = .white
        board[51] = .white
        board[61] = .black
        */

        
    }
    
    mutating func networkPath() -> (Color, [(Int, Int)])? {         // TODO
        if let side = network() {
            var p = [(Int, Int)]()
            for chip in self.path {
                p.append((chip / self.size, chip % self.size))
            }
            return (side, p)
        } else {
            return nil
        }
    }

    mutating func chooseMove() -> Move {
        /*printBoard()
        if moveNumber >= searchDepth {
            let (nextMove, _) = alpha_beta(color: self.color, alpha: -1, beta: 1)
            move(move: nextMove!, color: self.color)
            return nextMove!
        }*/
        let legal_moves : [Move] = legalMoves(color: self.color[true]!)
        let n = Int(arc4random_uniform(UInt32(legal_moves.count)))
        move(move: legal_moves[n], color: self.color[true]!)
        return legal_moves[n]
    }
    
    mutating func opponentMove(move m: Move) -> Bool {
        
        if invalidateMove(move: m, color: self.color[false]!) {
            moveNumber += 1
            board[coordinateToIndex(x: m.x1, y: m.y1)] = self.color[false]!
            if m.moveKind == .STEP {
                board[coordinateToIndex(x: m.x2, y: m.y2)] = nil
            } else if m.moveKind == .ADD {
                numOfChips[self.color[false]!] = numOfChips[self.color[false]!]! + 1
            }
            return true
        }
        return false
    }
    
    mutating func forceMove(move m: Move) -> Bool {
        if invalidateMove(move: m, color: self.color[true]!) {
            moveNumber += 1
            if m.moveKind == .STEP {
                board[coordinateToIndex(x: m.x2, y: m.y2)] = nil
            }
            board[coordinateToIndex(x: m.x1, y: m.y1)] = self.color[true]!
            if m.moveKind == .ADD {
                numOfChips[self.color[true]!] = numOfChips[self.color[true]!]! + 1
            }
            return true
        }
        return false
    }
    
    private mutating func undoMove(move m: Move, color c: Color) {
        if m.moveKind == .STEP {
            board[coordinateToIndex(x: m.x2, y: m.y2)] = c
        } else if m.moveKind == .ADD {
            numOfChips[c] = numOfChips[c]! - 1
        }
        board[coordinateToIndex(x: m.x1, y: m.y1)] = nil
    }
    
    private mutating func move(move m: Move, color c: Color) {
        
        if m.moveKind == .STEP {
            board[coordinateToIndex(x: m.x2, y: m.y2)] = nil
        } else if m.moveKind == .ADD {
            numOfChips[c] = numOfChips[c]! + 1
        }
        board[coordinateToIndex(x: m.x1, y: m.y1)] = c
    }
    
    
    private mutating func legalMoves(color c: Color) -> [Move] {
        var legal_moves = [Move]()
        print(numOfChips)
        if numOfChips[c]! >= chipsNumber {
            let from = getGrids(color: c)
            for i in 0 ..< from.count {
                let y = from[i] % self.size
                let x = from[i] / self.size
                for j in 0 ..< gridsNumber {
                    let guess = Move(to_x: j / size,to_y: j % size, from_x: x, from_y: y)
                    if invalidateMove(move: guess, color: c) {
                        legal_moves.append(guess)
                    }
                }
            }
        } else {
            for i in 0 ..< gridsNumber {
                let guess = Move(x: i / size, y: i % size)
                if invalidateMove(move: guess, color: c) {
                    legal_moves.append(guess)
                }
            }
        }
        //print("legal moves for \(c)")
        //print(legal_moves)
        return legal_moves
    }
    
    private func getGrids(color c : Color) -> [Int] {
        var ret = [Int]()
        for i in 0 ..< gridsNumber {
            if board[i] == c {
                ret.append(i)
            }
        }
        return ret
    }
    
    private mutating func invalidateMove(move m: Move, color c: Color) -> Bool {
        if numOfChips[c]! == chipsNumber && m.moveKind == .ADD {
            return false
        }
            
        if numOfChips[c]! < chipsNumber && m.moveKind == .STEP {
                return false
        }
    
        
        if (m.moveKind == .STEP) {
            let gridColor =  board[coordinateToIndex(x: m.x2, y: m.y2)]
            if c != gridColor {                // try to move opppnent's chip
                return false
            }
        }
        
        if board[coordinateToIndex(x: m.x1, y: m.y1)] != nil {  // occupied
            return false
        }
        if m.moveKind == .STEP && m.x1 == m.x2 && m.y1 == m.y2 {  // reject to move
            return false
        }
        if m.x1 == 0 && m.y1 == 0 || m.x1 == size - 1 && m.y1 == size - 1 || m.x1 == 0 && m.y1 == size - 1 || m.x1 == size - 1 && m.y1 == 0 {  // corners
            return false
        }
        if c == .white && (m.x1 == 0 || m.x1 == size - 1) {   // in opponent's goal area
            return false
        }
        if c == .black && (m.y1 == 0 || m.y1 == size - 1) {   // in opponent's goal area
            return false
        }
        move(move: m, color: c)
        
        if clusters(x: m.x1, y: m.y1, color: c) {
            undoMove(move: m, color: c)
            return false
        }  // clusters in current grid
        
        for i in getNeighbors(x: m.x1, y: m.y1) {       //clusters in the neighbors
            if board[i] == c && clusters(x: i / self.size, y: i % self.size, color: c) {
                undoMove(move: m, color: c)
                return false
            }
        }
        undoMove(move: m, color: c)
        return true
    }
    
    private func clusters(x x1: Int, y y1: Int, color c: Color) -> Bool {
        var flag = 0
        for i in getNeighbors(x: x1, y: y1) {
            if board[i] == c {
                flag = flag + 1
            }
            if flag >= 2 {
                return true
            }
        }
        return false
    }
    
    private func getNeighbors(x x1: Int, y y1: Int) -> [Int] {
        var neighbors = [Int]()
        if x1 > 0 && y1 > 0 {
            neighbors.append(coordinateToIndex(x: x1 - 1, y: y1 - 1))
        }
        if x1 > 0 {
            neighbors.append(coordinateToIndex(x: x1 - 1, y: y1))
        }
        if x1 > 0 && y1 < size - 1 {
            neighbors.append(coordinateToIndex(x: x1 - 1, y: y1 + 1))
        }
        if y1 > 0 {
            neighbors.append(coordinateToIndex(x: x1, y: y1 - 1))
        }
        if y1 < size - 1 {
            neighbors.append(coordinateToIndex(x: x1, y: y1 + 1))
        }
        if x1 < size - 1 && y1 > 0 {
            neighbors.append(coordinateToIndex(x: x1 + 1, y: y1 - 1))
        }
        if x1 < size - 1 {
            neighbors.append(coordinateToIndex(x: x1 + 1, y: y1))
        }
        if x1 < size - 1 && y1 < size - 1 {
            neighbors.append(coordinateToIndex(x: x1 + 1, y: y1 + 1))
        }
        return neighbors
    }
    
    func coordinateToIndex(x x1: Int, y y1: Int) -> Int {
        return y1 + x1 * size
    }
    
    
    
    private mutating func alpha_beta(side: Bool, alpha: Int, beta: Int) -> (Move?, Int) {
        var (myBestMove, myBestScore) = (Move(), (side ? -1 : 1))
        // var (replyBestMove, replyBestScore) = (Move(), (myBestScore == 1 ? -1 : 1))
        if side {
            myBestScore = alpha
        } else {
            myBestScore = beta
        }
        
        
        if let terminate = network() {
            let score = (terminate == self.color[true]! ? 1 : -1)
            if side && myBestScore < score {
                myBestScore = score
            }
            if !side && myBestScore > score {
                myBestScore = score
            }
            return (nil, myBestScore)
        }
        
        let legal_moves : [Move] = legalMoves(color: self.color[side]!)
        let n = Int(arc4random_uniform(UInt32(legal_moves.count)))
        myBestMove = legal_moves[n]
        
        var newAlpha = alpha
        var newBeta = beta
        for m in legal_moves {
            move(move: m, color: self.color[side]!)
            //printBoard()
            let (_, replyScore) = alpha_beta(side: !side, alpha: newAlpha, beta: newBeta)
            undoMove(move: m, color: self.color[side]!)
            if side && myBestScore < replyScore {
                myBestMove = m
                myBestScore = replyScore
                newAlpha = replyScore
            } else if !side && myBestScore > replyScore {
                myBestMove = m
                myBestScore = replyScore
                newBeta = replyScore
            }
            if newAlpha >= newBeta {
                return (myBestMove, myBestScore)
            }
        }
        return (myBestMove, myBestScore)
    }
    
    mutating func network() -> Color? {
        for i in 1 ..< size {
            if board[i] == .black {
                if let res = dfs(source: i, direction: .other, color: .black) {
                    print(res)
                    return res
                }
            }
        
            let indexForWhite = coordinateToIndex(x: i, y: 0)
            if board[indexForWhite] == .white {
                if let res = dfs(source: indexForWhite, direction: .other, color: .white) {
                    print(res)
                    return res
                }
            }
        }
        //print(".unset")
        return nil          //no network
     }
    
    private mutating func dfs(source s: Int, direction dir: Direction, color c: Color) -> Color? {
        let neighbors = nextInNetwork(indexInBoard: s, direction: dir, color: c)
        //print("neighbors of \(s): ")
        //print(neighbors)
        self.path.append(s)
        //print("path: \(path)")
        
        if s % size == self.size - 1 || s / size == self.size - 1 {
            if path.count >= minNetworkSize {
              return c
             } else {
             path.removeLast()
             return nil
             }
        }
        for neighbor in neighbors {
            if !path.contains(neighbor) {
                if let res = dfs(source: neighbor, direction: getDirection(fromIndex: s, toIndex: neighbor), color: c) {
                  return res
                }
            }
        }
        path.removeLast()
        return nil
    }
    
    private func getDirection(fromIndex from: Int , toIndex to: Int) -> Direction {
       
        if to / size == from / size {
          return .horizontal
        }
        if to % size == from % size {
           return .vertical
        }
    
        if max(to, from) <= min(to, from) + (size+1) * (size - 1 - min(to, from) % size) && (to - from) % (size+1) == 0 {
            return .mainDiag
        }
    
        if max(to, from) <= min(to, from) + (size - 1) * (min(to, from) % size) && (to - from) % (size - 1) == 0 {
            return .antiDiag
        }
        return .other
    }
    
    
    private func nextInNetwork(indexInBoard index: Int, direction dir: Direction, color c: Color) -> [Int] {
         var ret = [Int]()
         let x = index / size
         let y = index % size
         if dir != .mainDiag {
            var i = x + 1
            var j = y + 1
            while i < size && j < size {
                let indx = coordinateToIndex(x: i, y: j)
                if board[indx] != nil {
                   if board[indx] == c {
                       ret.append(indx)
                   }
                   break
                }
                i += 1
                j += 1
            }
    
            i = x - 1
            j = y - 1
            while i > 0 && j > 0 {
                let indx = coordinateToIndex(x: i, y: j)
                if board[indx] != nil {
                   if board[indx] == c {
                       ret.append(indx)
                   }
                    break
                }
                i -= 1
                j -= 1
            }
        }
    if dir != .antiDiag {
        var i = x - 1
        var j = y + 1
        while i > 0 && j < size {
            let indx = coordinateToIndex(x: i, y: j)
            if board[indx] != nil {
               if board[indx] == c {
                 ret.append(indx)
               }
               break
            }
            i -= 1
            j += 1
        }
        i = x + 1
        j = y - 1
        while j > 0 && i < size {
            let indx = coordinateToIndex(x: i, y: j)
               if board[indx] != nil {
                 if board[indx] == c {
                     ret.append(indx)
                 }
                 break
             }
            i += 1
            j -= 1
        }
    }
        
    if dir != .vertical && y != 0 {
        var i = x - 1
        while i > 0 {
            let indx = coordinateToIndex(x: i, y: y)
            if board[indx] != nil {
              if board[indx] == c {
                 ret.append(indx)
              }
              break
            }
            i -= 1
        }
    
        for i in x + 1 ..< size {
            let indx = coordinateToIndex(x: i, y: y)
            if board[indx] != nil {
                if board[indx] == c {
                  ret.append(indx)
                }
                break
            }
        }
    }
        
    if dir != .horizontal && x != 0 {
        var i = y - 1
         while i > 0 {
            let indx = coordinateToIndex(x: x, y: i)
            if board[indx] != nil {
               if board[indx] == c {
                   ret.append(indx)
               }
               break
            }
            i -= 1
          }
        
        for i in y + 1 ..< size {
            let indx = coordinateToIndex(x: x, y: i)
            if board[indx] != nil {
               if board[indx] == c {
                   ret.append(indx)
                }
               break
            }
        }
    }
        
    return ret
  }

    mutating func restart() {
        path.removeAll()
        board.replaceSubrange(0 ..< gridsNumber, with: repeatElement(nil, count: gridsNumber))
        numOfChips[.white] = 0
        numOfChips[.black] = 0
        
    }
    
    private func printBoard() {
        print("board is: ")
        for i in 0 ..< size {
            for j in 0 ..< size {
                if board[coordinateToIndex(x: i, y: j)] == nil {
                    print("-", separator: "  ", terminator: "")
                } else {
                    print("\(board[coordinateToIndex(x: i, y: j)]!)", separator: "  ", terminator: "")
                }
            }
            print("")
        }
        print("end board \n")
    }
    
}

