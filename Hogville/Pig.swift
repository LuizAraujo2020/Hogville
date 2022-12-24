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

    init(imageNamed name: String) {
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    /// This method simply adds the given point to the wayPoints array.
    func addMovingPoint(point: CGPoint) {
        wayPoints.append(point)
    }
    
    func move(dt: TimeInterval) {
        let currentPosition = position
        var newPosition = position
        
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
            position = newPosition

            //3
            if frame.contains(targetPoint) {
                wayPoints.remove(at: 0)
            }
        }
    }
    
    func createPathToMove() -> CGPath? {
        //1
        if wayPoints.count <= 1 {
            return nil
        }
        //2
        var ref = CGMutablePath()
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

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
