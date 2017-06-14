//
//  MLMovingGround.swift
//  Nimble Ninja
//
//  Created by Michael Leech on 1/24/15.
//  Copyright (c) 2015 CrashCourseCode. All rights reserved.
//

import Foundation
import SpriteKit

class MLMovingGround: SKSpriteNode {
    
    let NUMBER_OF_SEGMENTS = 20
    let COLOR_ONE = UIColor(red: 88.0/255.0, green: 148.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    let COLOR_TWO = UIColor(red: 120.0/255.0, green: 195.0/255.0, blue: 118.0/255.0, alpha: 1.0)
    
    init(size: CGSize) {
        super.init(texture: nil, color: UIColor.brown, size: CGSize(width: size.width*2, height: size.height))
        anchorPoint = CGPoint(x: 0, y: 0.5)
        
        for i in 0 ..< NUMBER_OF_SEGMENTS {
            var segmentColor: UIColor!
            if i % 2 == 0 {
                segmentColor = COLOR_ONE
            } else {
                segmentColor = COLOR_TWO
            }
            
            let segment = SKSpriteNode(color: segmentColor, size: CGSize(width: self.size.width / CGFloat(NUMBER_OF_SEGMENTS), height: self.size.height))
            segment.anchorPoint = CGPoint(x: 0.0, y: 0.5)
            segment.position = CGPoint(x: CGFloat(i)*segment.size.width, y: 0)
            addChild(segment)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSpeed(speed: CGFloat) {
        self.removeAllActions()
        let adjustedDuration = TimeInterval(frame.size.width / speed)
        
        let moveLeft = SKAction.moveBy(x: -frame.size.width/2, y: 0, duration: adjustedDuration/2)
        let resetPosition = SKAction.moveTo(x: 0, duration: 0)
        let moveSequence = SKAction.sequence([moveLeft, resetPosition])
        
        run(SKAction.repeatForever(moveSequence))
    }

    func start() {
        let adjustedDuration = TimeInterval(frame.size.width / kDefaultXToMovePerSecond)
        
        let moveLeft = SKAction.moveBy(x: -frame.size.width/2, y: 0, duration: adjustedDuration/2)
        let resetPosition = SKAction.moveTo(x: 0, duration: 0)
        let moveSequence = SKAction.sequence([moveLeft, resetPosition])
        
        run(SKAction.repeatForever(moveSequence))
    }
    
    func stop() {
        removeAllActions()
    }
}
