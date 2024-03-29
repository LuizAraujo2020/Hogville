//
//  GameScene.swift
//  Hogville
//
//  Created by Jean-Pierre Distler on 23.08.14.
//  Copyright (c) 2014 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

enum ColliderType: UInt32 {
    case Animal = 1
    case Food   = 2
}

class GameScene: SKScene {
    var movingPig: Pig?
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var homeNode = SKNode()
    var currentSpawnTime: TimeInterval = 10.0
    
    var gameOver = false
    
    override init(size: CGSize) {
        super.init(size: size)
        
        /// Disables gravity in your scene.
        physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        /// Registers your scene as the contact delegate of the physics world.
        physicsWorld.contactDelegate = self
        
        loadLevel()
        spawnAnimal()
    }
    
    func loadLevel () {
        /// Create the background.
        let bg = SKSpriteNode(imageNamed:"bg_2_grassy")
        bg.anchorPoint = CGPoint(x: 0, y: 0)
        addChild(bg)
        
        /// Create an SKSpriteNode for the trough and give it the name "food".
        /// You place the node near the center of the screen and add it to the scene.
        let foodNode = SKSpriteNode(imageNamed:"trough_3_full")
        foodNode.name = "food"
        foodNode.position = CGPoint(x:250, y:200)
        foodNode.zPosition = 1
        
        /// Adding Physics Bodies
        foodNode.physicsBody = SKPhysicsBody(rectangleOf: foodNode.size)
        foodNode.physicsBody!.categoryBitMask = ColliderType.Food.rawValue
        foodNode.physicsBody!.contactTestBitMask = ColliderType.Animal.rawValue
        foodNode.physicsBody!.isDynamic = false
        
        addChild(foodNode)
        
        /// Creates the barn and positions it in the lower-right corner of your scene.
        homeNode = SKSpriteNode(imageNamed: "barn")
        homeNode.name = "home"
        homeNode.position = CGPoint(x: 500, y: 20)
        homeNode.zPosition = 1
        addChild(homeNode)
        
        currentSpawnTime = 5.0
    }
    
    func spawnAnimal() {
        if gameOver {
            return
        }
        
        /// Decreases the time between spawns by 0.2 seconds every time the game spawns a pig.
        currentSpawnTime -= 0.2
        
        /// Ensure the spawn time never falls below one second,
        /// because anything faster than that would make the game too difficult,
        /// and if it hit zero, things would probably break.
        if currentSpawnTime < 1.0 {
            currentSpawnTime = 1.0
        }
        
        /// Here you create a pig and add it to the scene.
        let pig = Pig(imageNamed: "pig_1")
        pig.position = CGPoint(x: 20, y: Int(arc4random_uniform(300)))
        pig.name = "pig"
        
        addChild(pig)
        
        pig.moveRandom()
        
        run(SKAction.sequence(
            [SKAction.wait(forDuration: currentSpawnTime),
             SKAction.run({ self.spawnAnimal()}
                         )]
        ))
    }
    
    func handleAnimalCollision() {
        gameOver = true
        
        let gameOverLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.name = "label"
        gameOverLabel.fontSize = 35.0
        gameOverLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 + 20.0)
        gameOverLabel.zPosition = 5
        
        let tapLabel = SKLabelNode(fontNamed: "Thonburi-Bold")
        tapLabel.text = "Tap to restart."
        tapLabel.name = "label"
        tapLabel.fontSize = 25.0
        tapLabel.position = CGPointMake(size.width / 2.0, size.height / 2.0 - 20.0)
        tapLabel.zPosition = 5
        
        addChild(gameOverLabel)
        addChild(tapLabel)
    }
    
    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver {
            restartGame()
        }

        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "pig" {
                let pig = node as! Pig
                pig.clearWayPoints()
                pig.addMovingPoint(point: location)
                movingPig = pig
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if let pig = movingPig {
                pig.addMovingPoint(point: location)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        movingPig = nil
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        if !gameOver {
            dt = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            enumerateChildNodes(withName: "pig", using: {node, stop in
                let pig = node as! Pig
                pig.move(dt: self.dt)
            })
            
            drawLines()
        }
    }
    
    func drawLines() {
        /// You'll redraw the path every frame, so first you remove any old lines.
        /// To do so, you enumerate over all nodes with the name "line"
        /// and you remove them from the scene.
        enumerateChildNodes(withName: "line", using: {node, stop in
            node.removeFromParent()
        })
        
        /// Next, you enumerate over all the pigs in your scene.
        enumerateChildNodes(withName: "pig", using: {node, stop in
            /// For each pig, you use the method you just added and try to get a new path.
            /// If you got a path you create an SKShapeNode and assign the path to it's path property.
            /// After that you name it "line". Next you set the stroke color of the shape to gray
            /// and the fill color to nil. You can use any color you want,
            /// but I think gray will be visible on the most backgrounds.
            let pig = node as! Pig
            if let path = pig.createPathToMove() {
                let shapeNode = SKShapeNode()
                shapeNode.path = path
                shapeNode.name = "line"
                shapeNode.strokeColor = UIColor.gray
                shapeNode.lineWidth = 2
                shapeNode.zPosition = 1
                
                /// Finally, you add shapeNode to your scene so that the scene will render it.
                self.addChild(shapeNode)
            }
        })
    }
    
    func restartGame() {
        enumerateChildNodes(withName: "line", using: {node, stop in
            node.removeFromParent()
        })
        
        enumerateChildNodes(withName: "pig", using: {node, stop in
            node.removeFromParent()
        })
        
        enumerateChildNodes(withName: "label", using: {node, stop in
            node.removeFromParent()
        })
        
        currentSpawnTime = 5.0
        gameOver = false
        spawnAnimal()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameScene: SKPhysicsContactDelegate {

    func didBegin(_ contact: SKPhysicsContact) {
        /// These two lines give you the nodes that just collided.
        /// There is no specific order for the nodes,
        /// so you have to check the objects yourself if you care which is which.
        let firstNode  = contact.bodyA.node
        let secondNode = contact.bodyB.node

        /// You perform a bitwise-OR of the categories of the two collided nodes
        /// and store it in collision.
        let collision = firstNode!.physicsBody!.categoryBitMask | secondNode!.physicsBody!.categoryBitMask

        /// Figure out what kind of collision occurred
        /// by comparing collision with the bit mask for an animal/animal or animal/food collision.
        if collision == ColliderType.Animal.rawValue | ColliderType.Animal.rawValue {
            handleAnimalCollision()
            
        } else if collision == ColliderType.Animal.rawValue | ColliderType.Food.rawValue {
            var pig: Pig!
            /// Figure out which node is the pig and
            /// call eat on it.
            if firstNode!.name == "pig" {
                pig = firstNode as? Pig
                pig.eat()
            } else {
                pig = secondNode as? Pig
                pig.eat()
            }

        } else {
            NSLog("Error: Unknown collision category \(collision)")
        }
    }
}
