import SpriteKit

extension Array {
    
    func sample() -> (ele: Element, index: Int) {
        let randomIndex = Int(arc4random()) % count
        return (ele: self[randomIndex], index: randomIndex)
    }
    
    func cleanUp(withAnswers: [[Float]]) -> (this: [[Float]], answers: [[Float]]) {
        var amountZero = 0
        var amountOne = 0
        var result: (this: [[Float]], answers: [[Float]]) = (this: [], answers: [])
        var this: [[Float]] = []
        var answers: [[Float]] = []
        for (index, _) in self.enumerated() {
            if withAnswers[index] == [0] {
                amountZero += 1
            } else if withAnswers[index] == [1] {
                amountOne += 1
            }
        }
        for i in self {
            this.append(i as! [Float])
        }
        answers = withAnswers
        while (amountOne) < amountZero {
            var continueIt = true
            for (index, _) in this.enumerated() {
                if continueIt {
                    if answers[index] == [0] {
                        answers.remove(at: index)
                        this.remove(at: index)
                        continueIt = false
                    }
                }
            }
            amountOne = 0
            amountZero = 0
            for (index, _) in this.enumerated() {
                if answers[index] == [0] {
                    amountZero += 1
                } else if answers[index] == [1] {
                    amountOne += 1
                }
            }
        }
        result = (this: this, answers: answers)
        return result
    }
    
}

func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
}

var network = FFNN(inputs: 1, hidden: 300, outputs: 1)

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var movingGround: MLMovingGround!
    var hero: MLHero!
    var cloudGenerator: MLCloudGenerator!
    var wallGenerator: MLWallGenerator!
    
    var isStarted = false
    var isGameOver = false
    
    var closestObstacleX = 0
    var currentSpeed: Float = 0
    
    var timerInterval = 1.0
    
    var params: [[Float]] = []
    var doneFor: [Float] = []
    var answers: [[Float]] = []
    
    var neuralPlay = false
    
    var lastFlip = false
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 159.0/255.0, green: 201.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        
        addMovingGround()
        addHero()
        addCloudGenerator()
        addWallGenerator()
        addTapToStartLabel()
        addPointsLabels()
        addPhysicsWorld()
        loadHighscore()
        
//        **UNCOMMENT NEXT LINE TO START THE GAME OFF WITH "neuralPlay"**
//        neuralPlay = true
        
    }
    
    func addMovingGround() {
        movingGround = MLMovingGround(size: CGSize(width: view!.frame.width, height: kMLGroundHeight))
        movingGround.position = CGPoint(x: 0, y: view!.frame.size.height/2)
        addChild(movingGround)
    }
    
    func addHero() {
        hero = MLHero()
        hero.position = CGPoint(x: 70, y: movingGround.position.y + movingGround.frame.size.height/2 + hero.frame.size.height/2)
        addChild(hero)
        hero.breathe()
    }
    
    func addCloudGenerator() {
        cloudGenerator = MLCloudGenerator(color: UIColor.clear, size: view!.frame.size)
        cloudGenerator.position = view!.center
        addChild(cloudGenerator)
        cloudGenerator.populate(7)
        cloudGenerator.startGeneratingWithSpawnTime(5)
    }
    
    func addWallGenerator() {
        wallGenerator = MLWallGenerator(color: UIColor.clear, size: view!.frame.size)
        wallGenerator.position = view!.center
        addChild(wallGenerator)
    }
    
    func addTapToStartLabel() {
        let tapToStartLabel = SKLabelNode(text: "Tap to start!")
        tapToStartLabel.name = "tapToStartLabel"
        tapToStartLabel.position.x = view!.center.x
        tapToStartLabel.position.y = view!.center.y + 40
        tapToStartLabel.fontName = "Helvetica"
        tapToStartLabel.fontColor = UIColor.black
        tapToStartLabel.fontSize = 22.0
        addChild(tapToStartLabel)
        tapToStartLabel.run(blinkAnimation())
    }
    
    func addPointsLabels() {
        let pointsLabel = MLPointsLabel(num: 0)
        pointsLabel.position = CGPoint(x: 20.0, y: view!.frame.size.height - 35)
        pointsLabel.name = "pointsLabel"
        addChild(pointsLabel)
        
        let highscoreLabel = MLPointsLabel(num: 0)
        highscoreLabel.name = "highscoreLabel"
        highscoreLabel.position = CGPoint(x: view!.frame.size.width - 20, y: view!.frame.size.height - 35)
        addChild(highscoreLabel)
        
        let highscoreTextLabel = SKLabelNode(text: "High")
        highscoreTextLabel.fontColor = UIColor.black
        highscoreTextLabel.fontSize = 14.0
        highscoreTextLabel.fontName = "Helvetica"
        highscoreTextLabel.position = CGPoint(x: 0, y: -20)
        highscoreLabel.addChild(highscoreTextLabel)
    }
    
    func addPhysicsWorld() {
        physicsWorld.contactDelegate = self
    }
    
    func loadHighscore() {
        let defaults = UserDefaults.standard
        
        let highscoreLabel = childNode(withName: "highscoreLabel") as! MLPointsLabel
        highscoreLabel.setTo(defaults.integer(forKey: "highscore"))
    }
    
    // MARK: - Game Lifecycle
    func start() {
        isStarted = true
        isGameOver = false
        
        let tapToStartLabel = childNode(withName: "tapToStartLabel")
        tapToStartLabel?.removeFromParent()
        
        hero.stop()
        hero.startRunning()
        movingGround.start()
        
        wallGenerator.startGeneratingWallsEvery(1)
    }
    
    func gameOver() {
        isGameOver = true
        
        kDefaultXToMovePerSecond = 320
        
        // stop everything
        hero.fall()
        wallGenerator.stopWalls()
        movingGround.stop()
        hero.stop()
        
        // create game over label
        let gameOverLabel = SKLabelNode(text: "Game Over!")
        gameOverLabel.fontColor = UIColor.black
        gameOverLabel.fontName = "Helvetica"
        gameOverLabel.position.x = view!.center.x
        gameOverLabel.position.y = view!.center.y + 40
        gameOverLabel.fontSize = 22.0
        addChild(gameOverLabel)
        gameOverLabel.run(blinkAnimation())
        
        
        // save current points label value
        let pointsLabel = childNode(withName: "pointsLabel") as! MLPointsLabel
        let highscoreLabel = childNode(withName: "highscoreLabel") as! MLPointsLabel
        
        if highscoreLabel.number < pointsLabel.number {
            highscoreLabel.setTo(pointsLabel.number)
            
            let defaults = UserDefaults.standard
            defaults.set(highscoreLabel.number, forKey: "highscore")
        }
        
        if !(neuralPlay) {
            let res = params.cleanUp(withAnswers: answers)
            print("Old: \(params)")
            params = res.this
            answers = res.answers
            print("New: \(params)")
            print(answers)
            _ = try! network.train(inputs: params, answers: answers, testInputs: params, testAnswers: answers, errorThreshold: 0.1)
            print(network.getWeights())
        }
        
        neuralPlay = true
    }
    
    func restart() {
        cloudGenerator.stopGenerating()
        
        let newScene = GameScene(size: view!.bounds.size)
        newScene.scaleMode = .aspectFill
        newScene.neuralPlay = true
        
        view!.presentScene(newScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restart()
        } else if !isStarted {
            start()
        } else {
            params.append([Float(closestObstacleX)])
            answers.append([1])
            doneFor.append(Float(closestObstacleX))
            hero.flip()
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        
        if wallGenerator.wallTrackers.count > 0 {
        
            let wall = wallGenerator.wallTrackers[0] as MLWall
            
            let wallLocation = wallGenerator.convert(wall.position, to: self)
            if wallLocation.x < hero.position.x {
                wallGenerator.wallTrackers.remove(at: 0)
                
                let pointsLabel = childNode(withName: "pointsLabel") as! MLPointsLabel
                pointsLabel.increment()
                
                
            }
        }
        
        var selected = false
        var indexMinus = 0
        
        for (index, i) in wallGenerator.walls.enumerated() {
            if !(wallGenerator.intersects(i)) {
                indexMinus += 1
                wallGenerator.walls.remove(at: index)
            }
            if i.up == (hero.isUpsideDown ? 0 : 1) && !selected {
                closestObstacleX = Int(i.position.x)
                i.removeFromParent()
                i.color = UIColor.red
                wallGenerator.addChild(i)
                selected = true
                continue
            }
            i.color = UIColor.black
        }
        
        if closestObstacleX != 0 && !(doneFor.contains(Float(closestObstacleX))) {
            params.append([Float(closestObstacleX)])
            answers.append([0])
        }
        
        if neuralPlay && isStarted && !(isGameOver) {
            let networkValue = try! network.update(inputs: [Float(closestObstacleX)]).first!
            let networkWantsToFlip = networkValue > 0.99
            print("Network value: \(networkValue) \(networkWantsToFlip)")
            if networkWantsToFlip && !(lastFlip) {
                hero.flip()
                lastFlip = true
            } else if !(networkWantsToFlip) {
                lastFlip = false
            }
        }
        
    }
    
    // MARK: - SKPhysicsContactDelegate
    func didBegin(_ contact: SKPhysicsContact) {
        if !isGameOver {
            gameOver()
        }
    }
    
    // MARK: - Animations
    func blinkAnimation() -> SKAction {
        let duration = 0.4
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        return SKAction.repeatForever(blink)
    }
}
