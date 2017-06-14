//
//  MLCloudGenerator.swift
//  Nimble Ninja
//
//  Created by Michael Leech on 1/30/15.
//  Copyright (c) 2015 CrashCourseCode. All rights reserved.
//

import Foundation
import SpriteKit

class MLCloudGenerator: SKSpriteNode {
    
    let CLOUD_WIDTH: CGFloat = 125.0
    let CLOUD_HEIGHT: CGFloat = 55.0
    
    var generationTimer: Timer!
    
    func populate(_ num: Int) {
        for i in 0 ..< num {
            let cloud = MLCloud(size: CGSize(width: CLOUD_WIDTH, height: CLOUD_HEIGHT))
            let x = CGFloat(arc4random_uniform(UInt32(size.width))) - size.width/2
            let y = CGFloat(arc4random_uniform(UInt32(size.height))) - size.height/2
            cloud.position = CGPoint(x: x, y: y)
            cloud.zPosition = -1
            addChild(cloud)
        }
    }
    
    func startGeneratingWithSpawnTime(_ seconds: TimeInterval) {
        generationTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(MLCloudGenerator.generateCloud), userInfo: nil, repeats: true)
    }
    
    func stopGenerating() {
        generationTimer.invalidate()
    }
        
    @objc func generateCloud() {
        let x = size.width/2 + CLOUD_WIDTH/2
        let y = CGFloat(arc4random_uniform(UInt32(size.height))) - size.height/2
        let cloud = MLCloud(size: CGSize(width: CLOUD_WIDTH, height: CLOUD_HEIGHT))
        cloud.position = CGPoint(x: x, y: y)
        cloud.zPosition = -1
        addChild(cloud)
    }
    
}
