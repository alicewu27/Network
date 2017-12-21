//
//  Chip.swift
//  Network
//
//  Created by huayuan wu on 8/25/17.
//  Copyright © 2017 huayuan wu. All rights reserved.
//

import UIKit

class Chip: UIView {
    var color = UIColor.white
    //let scale : CGFloat = 0.9
    var selected = false {
        didSet{
            setNeedsDisplay()
        }
    }
    var radius : CGFloat {
        return bounds.width / 2
    }
    var origin : CGPoint {
        return CGPoint(x: bounds.midX - radius, y: bounds.midY - radius)
    }
    
    func chipGenerator()  -> UIBezierPath{
        let chip = UIBezierPath(ovalIn: CGRect(x: origin.x, y: origin.y, width: radius*2, height: radius*2))
        return chip
    }
    override init(frame: CGRect) {
        super.init(frame: frame)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        self.isOpaque = false
        UIColor.brown.setFill()
        UIRectFill(rect)
        self.backgroundColor = UIColor.brown
        if selected {
            self.alpha = 0.3
        } else {
            self.alpha = 1
        }
        let chip = chipGenerator()
        self.color.setFill()
        chip.stroke()
        chip.fill()
    }

}
