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
    case Food = 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var movingPig: Pig?
    var lastUpdateTime: TimeInterval = 0.0
    var dt: TimeInterval = 0.0
    
    var homeNode = SKNode()
    var currentSpawnTime: TimeInterval = 5.0

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
        
        run(SKAction.sequence(
                           [SKAction.wait(forDuration: currentSpawnTime),
                                SKAction.run({ self.spawnAnimal()}
                           )]
            ))
    }

    
    // MARK: Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            
            if node.name == "pig" {
                let pig = node as! Pig
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
        dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        enumerateChildNodes(withName: "pig", using: {node, stop in
            let pig = node as! Pig
            pig.move(dt: self.dt)
        })
        
        drawLines()

    }
    
    func drawLines() {
        //1
        enumerateChildNodes(withName: "line", using: {node, stop in
            node.removeFromParent()
        })
        
        //2
        enumerateChildNodes(withName: "pig", using: {node, stop in
            //3
            let pig = node as! Pig
            if let path = pig.createPathToMove() {
                let shapeNode = SKShapeNode()
                shapeNode.path = path
                shapeNode.name = "line"
                shapeNode.strokeColor = UIColor.gray
                shapeNode.lineWidth = 2
                shapeNode.zPosition = 1
                
                self.addChild(shapeNode)
            }
        })
    }

    func didBegin(_ contact: SKPhysicsContact) {
        print("➡️ Entrou na func\(#function)")
        /// These two lines give you the nodes that just collided.
        /// There is no specific order for the nodes,
        /// so you have to check the objects yourself if you care which is which.
        let firstNode = contact.bodyA.node
        let secondNode = contact.bodyB.node

        /// You perform a bitwise-OR of the categories of the two collided nodes
        /// and store it in collision.
        let collision = firstNode!.physicsBody!.categoryBitMask | secondNode!.physicsBody!.categoryBitMask

        /// Figure out what kind of collision occurred
        /// by comparing collision with the bit mask for an animal/animal or animal/food collision.
        if collision == ColliderType.Animal.rawValue | ColliderType.Animal.rawValue {
            NSLog("Animal collision detected")
            
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
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
