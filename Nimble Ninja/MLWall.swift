//
//  MLWall.swift
//  Nimble Ninja
//
//  Created by Michael Leech on 2/3/15.
//  Copyright (c) 2015 CrashCourseCode. All rights reserved.
//

import Foundation
import SpriteKit

class MLWall: SKSpriteNode {
   
    let WALL_WIDTH: CGFloat = 30.0
    let WALL_HEIGHT: CGFloat = 50.0
    let WALL_COLOR = UIColor.black
    
    var up: Int!
    
    init(_up: Int) {
        let size = CGSize(width: WALL_WIDTH, height: WALL_HEIGHT)
        super.init(texture: nil, color: WALL_COLOR, size: size)
        
        up = _up
        
        loadPhysicsBodyWithSize(size)
        startMoving()
    }
    
    func loadPhysicsBodyWithSize(_ size: CGSize) {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.categoryBitMask = wallCategory
        physicsBody?.affectedByGravity = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSpeed(speed: CGFloat) {
        self.removeAllActions()
        let moveLeft = SKAction.moveBy(x: speed, y: 0, duration: 1)
        run(SKAction.repeatForever(moveLeft))
    }
    
    func startMoving() {
        let moveLeft = SKAction.moveBy(x: -kDefaultXToMovePerSecond, y: 0, duration: 1)
        run(SKAction.repeatForever(moveLeft))
    }
    
    func stopMoving() {
        removeAllActions()
    }
    
}
