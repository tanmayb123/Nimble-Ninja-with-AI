//
//  MLWallGenerator.swift
//  Nimble Ninja
//
//  Created by Michael Leech on 2/3/15.
//  Copyright (c) 2015 CrashCourseCode. All rights reserved.
//

import Foundation
import SpriteKit

class MLWallGenerator: SKSpriteNode {
    
    var generationTimer: Timer?
    var walls = [MLWall]()
    var wallTrackers = [MLWall]()
    
    func startGeneratingWallsEvery(_ seconds: TimeInterval) {
        generationTimer?.invalidate()
        generationTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(MLWallGenerator.generateWall), userInfo: nil, repeats: true)
    }
    
    func stopGenerating() {
        generationTimer?.invalidate()
    }
    
    @objc func generateWall() {
        var scale: CGFloat
        let rand = arc4random_uniform(2)
        if rand == 0 {
            scale = -1.0
        } else {
            scale = 1.0
        }
        
        let wall = MLWall(_up: scale == 1.0 ? 1 : 0)
        wall.position.x = size.width/2 + wall.size.width/2
        wall.position.y = scale * (kMLGroundHeight/2 + wall.size.height/2)
        walls.append(wall)
        wallTrackers.append(wall)
        addChild(wall)
    }
    
    func stopWalls() {
        stopGenerating()
        for wall in walls {
            wall.stopMoving()
        }
    }
    
}
