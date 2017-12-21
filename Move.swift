//
//  File.swift
//  Network
//
//  Created by huayuan wu on 8/23/17.
//  Copyright © 2017 huayuan wu. All rights reserved.
//

import Foundation

struct Move {
    
    enum MoveKind {
        case QUIT
        case ADD
        case STEP
    }
    var moveKind : MoveKind = .ADD
    
    var x1 : Int = 0
    var y1 : Int = 0
    var x2 : Int = 0
    var y2 : Int = 0
    
    init(to_x xx1: Int, to_y yy1: Int, from_x xx2: Int, from_y yy2: Int) {
        moveKind = .STEP
        x1 = xx1
        y1 = yy1
        x2 = xx2
        y2 = yy2
    }
    
    init(x xx1: Int, y yy1: Int) {
        moveKind = .ADD
        x1 = xx1
        y1 = yy1
    }
    
    init() {
        moveKind = .QUIT
    }
    
    func toString() -> String {
        switch (moveKind) {
        case .QUIT:
            return "[quit]"
        case .ADD:
            return "[add to \(x1) \(y1)]"
        default:
            return "[step from \(x2) \(y2) to \(x1) \(y1)]"
        }
    }
 }



