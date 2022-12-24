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
        physicsBody!.collisionBitMask = 0
    }
    
    /// This method simply adds the given point to the wayPoints array.
    func addMovingPoint(point: CGPoint) {
        wayPoints.append(point)
    }
    
    func move(dt: TimeInterval) {
        let currentPosition = position
        var newPosition = position
        
        /// Animate the Pig.
        if(action(forKey: "moveAction") == nil) {
            run(moveAnimation, withKey:"moveAction")
        }

        //1
        if wayPoints.count > 0 {
            let targetPoint = wayPoints[0]
            
            //Code that calculates and updates the pig’s new position along the path between the waypoints.
            //1
            let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
            let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
            let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
            velocity = CGPoint(x: direction.x * POINTS_PER_SEC, y: direction.y * POINTS_PER_SEC)
            
            //2
            newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(dt), y:currentPosition.y + velocity.y * CGFloat(dt))
            position = checkBoundaries(position: newPosition)

            //3
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
    }
    
    func createPathToMove() -> CGPath? {
        //1
        if wayPoints.count <= 1 {
            return nil
        }
        //2
        let ref = CGMutablePath()
        //        let line_path:CGMutablePath = CGMutablePath()
        //3
        for i in 0..<wayPoints.count {
            let p = wayPoints[i]
            
            //4
            if i == 0 {
                ref.move(to: p)
                //                CGPathMoveToPoint(ref, NULL, CGFloat(p.x), CGFloat(p.y))
                //                CGPathMoveToPoint(ref, UnsafePointer<CoreFoundation.CGAffineTransform>, p.x, p.y)
            } else {
                //                CGPathAddLineToPoint(ref, nil, p.x, p.y)
                ref.addLine(to: p)
            }
        }
        
        return ref
    }
    
    func checkBoundaries(position: CGPoint) -> CGPoint {
        //1
        var newVelocity = velocity
        var newPosition = position
        
        //2
        let bottomLeft = CGPoint(x: 0, y: 0)
        let topRight = CGPoint(x:scene!.size.width, y:scene!.size.height)
        
        //3
        if newPosition.x <= bottomLeft.x {
            newPosition.x = bottomLeft.x
            newVelocity.x = -newVelocity.x
        } else if newPosition.x >= topRight.x {
            newPosition.x = topRight.x
            newVelocity.x = -newVelocity.x
        }
        
        if newPosition.y <= bottomLeft.y {
            newPosition.y = bottomLeft.y
            newVelocity.y = -newVelocity.y
        } else if newPosition.y >= topRight.y {
            newPosition.y = topRight.y
            newVelocity.y = -newVelocity.y
        }
        
        velocity = newVelocity
        
        return newPosition
    }

    required init(coder aDecoder: NSCoder) {
        let textures = [SKTexture(imageNamed:"pig_1"), SKTexture(imageNamed:"pig_2"), SKTexture(imageNamed:"pig_3")]
        moveAnimation = SKAction.animate(with: textures, timePerFrame:0.1)

        super.init(coder: aDecoder)!
    }
}
