//
//  Pig.swift
//  Hogville
//
//  Created by Luiz Araujo on 24/12/22.
//  Copyright © 2022 Jean-Pierre Distler. All rights reserved.
//

import SpriteKit

class Pig: SKSpriteNode {
    let POINTS_PER_SEC: CGFloat = 80.0
    var wayPoints: [CGPoint] = []
    var velocity = CGPoint(x: 0, y: 0)
    
    var moveAnimation: SKAction

    var hungry = true
    var eating = false

    /// End Game
    /// Flag to mark pigs while they are in the process of leaving the game.
    var removing = false

    init(imageNamed name: String) {
        let texture = SKTexture(imageNamed: name)
        let textures = [SKTexture(imageNamed:"pig_1"),
                        SKTexture(imageNamed:"pig_2"),
                        SKTexture(imageNamed:"pig_3")]
        moveAnimation = SKAction.animate(with: textures, timePerFrame:0.1)

        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        /// Adding Physics Bodies
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2.0)
        physicsBody!.categoryBitMask = ColliderType.Animal.rawValue
        /// Indicate that this node should produce contact notifications
        /// whenever it touches any other physics body that belongs to any category inside the bit mask.
        /// Allow pigs to pass right through other physics objects.
        physicsBody!.contactTestBitMask = ColliderType.Animal.rawValue | ColliderType.Food.rawValue
        physicsBody!.collisionBitMask = 0
    }
    
    /// This method simply adds the given point to the wayPoints array.
    func addMovingPoint(point: CGPoint) {
        wayPoints.append(point)
    }
    
    func move(dt: TimeInterval) {
        if !eating {
            let currentPosition = position
            var newPosition = position
            
            /// Animate the Pig.
            if(action(forKey: "moveAction") == nil) {
                run(moveAnimation, withKey:"moveAction")
            }
            
            /// Check to ensure there are waypoints left in the array.
            if wayPoints.count > 0 {
                let targetPoint = wayPoints[0]
                
                /// Code that calculates and updates the pig’s new position along the path between the waypoints.
                /// You calculate a vector that points in the direction the pig should travel
                /// and has a length representing the distance the pig should move in dt seconds.
                let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
                let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
                let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
                velocity = CGPoint(x: direction.x * POINTS_PER_SEC, y: direction.y * POINTS_PER_SEC)
                
                /// You calculate the pig’s new position by multiplying velocity by dt
                /// and adding the result to the pig’s current position. Because velocity stores the distance the pig should travel in one second and dt holds the number of seconds that have passed since the last call to move,
                /// multiplying the two results in the distance the pig should travel in dt seconds.
                newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
                position = checkBoundaries(position: newPosition)
                
                /// Finally, you check if the pig has reached the waypoint
                /// by seeing if the pig’s frame contains the targetPoint.
                /// In this case, you remove the point from the array
                /// so that your next call to move will use the next point.
                /// Note that it’s important to check if the frame contains
                /// the target point (rather than checking if the position equals the target point),
                /// effectively stopping the pig when he’s “close enough”.
                /// That makes some of the calculations later a bit easier.
                if frame.contains(targetPoint) {
                    wayPoints.remove(at: 0)
                }
            } else {
                newPosition = CGPoint(x: currentPosition.x + velocity.x * CGFloat(dt),
                                      y: currentPosition.y + velocity.y * CGFloat(dt))
                position = checkBoundaries(position: newPosition)
            }
            
            /// Rotate the pig so that it faces the direction it’s moving.
            zRotation = atan2(CGFloat(velocity.y), CGFloat(velocity.x)) + CGFloat(M_PI_2)
            
            checkForHome()
        }/// End: ` if !eating `
    }
    
    func createPathToMove() -> CGPath? {
        /// First, you check if you have enough waypoints to create a path.
        /// A path has at least on line and a line needs at least 2 points.
        /// If you have less than 2 points you just return nil.
        if wayPoints.count <= 1 {
            return nil
        }
        /// Then, you create a mutable CGPathRef so you can add points to it.
        let ref = CGMutablePath()
        /// This for loop iterates over all the stored waypoints to build the path.
        for i in 0..<wayPoints.count {
            let p = wayPoints[i]
            
            /// Check if the path is just starting, indicated by an i value of zero.
            if i == 0 {
                ref.move(to: p)
            } else {
                ref.addLine(to: p)
            }
        }
        
        return ref
    }
    
    func moveRandom() {
        /// Remove all existing waypoints to make the path truly random.
        wayPoints.removeAll(keepingCapacity: false)//removeAll(keepCapacity:false)
        
        /// Get the width and height of the scene to have a range for the random numbers.
        let width = scene!.frame.width
        let height = scene!.frame.height
        
        /// Create a random CGPoint inside your scene and add it as a waypoint.
        /// This new waypoint is enough to get the pig moving again.
        let randomPoint = CGPoint(x:Int(arc4random_uniform(UInt32(width))),
                                  y:Int(arc4random_uniform(UInt32(height))))
        wayPoints.append(randomPoint)
        wayPoints.append(CGPoint(x:randomPoint.x + 1, y:randomPoint.y + 1))
    }

    func checkBoundaries(position: CGPoint) -> CGPoint {
        /// First, you assign the current velocity and point to local variables.
        var newVelocity = velocity
        var newPosition = position
        
        /// Here you define the important points on the screen.
        /// You can use bottomLeft to check if the pig is moving off screen from the left
        /// or bottom sides and topRight to check the top and right sides of the screen.
        /// You perform these checks inside the following if statements, one for each side of the screen.
        let bottomLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x:scene!.size.width, y:scene!.size.height)
        
        /// This first if statement checks the x value of newPosition.
        /// If this value is zero or less, the pig is leaving the screen from the left side.
        /// To avoid this, you set the pig's x-position to the left boundary—zero—and reverse
        /// the x-component of the velocity so the pig starts moving in the opposite direction.
        if newPosition.x <= bottomLeft.x {
            newPosition.x = bottomLeft.x
            newVelocity.x = -newVelocity.x
        } else if newPosition.x >= topRight.x {
            newPosition.x = topRight.x
            newVelocity.x = -newVelocity.x
        }
        
        /// This other if statements do the same for the remaining three bounds of the screen.
        if newPosition.y <= bottomLeft.y {
            newPosition.y = bottomLeft.y
            newVelocity.y = -newVelocity.y
        } else if newPosition.y >= topRight.y {
            newPosition.y = topRight.y
            newVelocity.y = -newVelocity.y
        }
        
        /// At the end, you change velocity to whatever value you calculated and then return newPosition.
        velocity = newVelocity
        
        return newPosition
    }
    
    func eat() {
        /// When the pig is hungry, it will start eating.
        if hungry {
            /// You remove the walking animation and set eating to true.
            /// Your pig will stand still on the trough and eat.
            /// Once it finishes eating it is no longer hungry,
            /// so you set hungry to false.
            removeAction(forKey: "moveAction")
            eating = true
            hungry = false
            
            /// Like everything in life, eating takes time,
            /// so you run a sequence action that waits for a second and then executes blockAction, which sets eating to false and calls the method you just added to start the pig walking again.
            /// You could decrease the eating time to make the game easier.
            let blockAction = SKAction.run({
                self.eating = false
                self.moveRandom()
            })
            
            run(SKAction.sequence([SKAction.wait(forDuration: 1.0), blockAction]))
        }
    }
    
    /// END GAME
    func checkForHome() {
        /// Hungry pigs won’t go to sleep, so you first check if the pig is hungry
        /// or is already set to be removed from the game.
        if hungry || removing {
            return
        }
        
        /// Here you get the homeNode.
        let s = scene as! GameScene
        let homeNode = s.homeNode
        
        /// You then check if the pig's frame overlaps the barn's. If that's the case,
        /// you set the pig's removing flag to true and clear its waypoints
        /// and any running actions.
        if frame.intersects(homeNode.frame) {
            removing = true
            
            wayPoints.removeAll(keepingCapacity: false)
            removeAllActions()
            
            /// Here you run another sequence of actions that first runs a group of actions simultaneously,
            /// and when those are done it removes the pig from the scene.
            /// The group of actions fades out the pig's sprite while it moves the pig to the center of the barn.
            run(SKAction.sequence([
                SKAction.group([SKAction.fadeAlpha(to: 0.0, duration: 0.5),
                                SKAction.move(to: homeNode.position, duration: 0.5)]),
                SKAction.removeFromParent()]))
        }
    }
    
    func clearWayPoints() {
        wayPoints.removeAll(keepingCapacity: false)
    }

    required init(coder aDecoder: NSCoder) {
        let textures = [SKTexture(imageNamed:"pig_1"), SKTexture(imageNamed:"pig_2"), SKTexture(imageNamed:"pig_3")]
        moveAnimation = SKAction.animate(with: textures, timePerFrame:0.1)

        super.init(coder: aDecoder)!
    }
}
