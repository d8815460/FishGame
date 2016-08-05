//
//  PondScene.swift(
//  MakeSchoolOfFish
//
//  Created by Dion Larson on 6/28/16.
//  Copyright (c) 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

class PondScene: SKScene {
    var allFish = [Fish]()
    var activeFood =  [CGPoint]()
    var frameCount = 0
    var foodParticles: SKEmitterNode?
    var ripple: SKSpriteNode?
    var tapTimer: NSTimer?
    var touchLocation: CGPoint?
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        touchLocation = touch.locationInNode(self)
        if touch.tapCount == 2 {
            tapTimer?.invalidate()
            tapTimer = nil
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if touch.tapCount == 1 {
            tapTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(addFood), userInfo: nil, repeats: false)
        } else if touch.tapCount == 2 {
            addRipple()
        } else {
            print("too many taps!")
        }
    }
    
    func addFood() {
        foodParticles?.removeFromParent()
        foodParticles = SKEmitterNode(fileNamed: "Food")
        foodParticles?.zPosition = 25
        if let foodParticles = foodParticles, location = touchLocation {
            foodParticles.position = location
            addChild(foodParticles)
            
            let removeOnFinish = SKAction.runBlock({
                self.foodParticles?.removeFromParent()
                self.foodParticles?.removeAllActions()
                self.foodParticles = nil
            })
            foodParticles.runAction(SKAction.sequence([SKAction.waitForDuration(7.5), removeOnFinish]))
        }
    }
    
    func addRipple() {
        ripple?.removeFromParent()
        ripple = SKReferenceNode(fileNamed: "Ripple")?.childNodeWithName("ripple") as? SKSpriteNode
        ripple?.removeFromParent()
        ripple?.alpha = 0.0
        ripple?.zPosition = 20
        if let ripple = ripple, location = touchLocation {
            ripple.position = location
            addChild(ripple)
            
            let removeOnFinish = SKAction.runBlock({
                self.ripple?.removeFromParent()
                self.ripple?.removeAllActions()
                self.ripple = nil
            })
            ripple.runAction(SKAction.sequence([SKAction.waitForDuration(3), removeOnFinish]))
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        updateFish()
        updateSprites()
        restrainFish()
        frameCount += 1
    }
    
    override func didMoveToView(view: SKView) {
        for _ in 1...NumberOfFish {
            let fish = createFish()
            addChild(fish)
            allFish.append(fish)
        }
    }
    
    func createFish() -> Fish {
        let fish = SKReferenceNode(fileNamed: "Fish")!.childNodeWithName("fish") as! Fish
        fish.removeFromParent()
        fish.position = CGPoint(x: CGFloat.random(min: 0, max: size.width),
                                y: CGFloat.random(min: 0, max: size.height))
        fish.velocity = CGPoint(angle: CGFloat.random(min: 0, max: 2 * π)) * StartingSpeed
        fish.delegate = self
        return fish
    }
    
    func updateFish() {
        for fish in allFish {
            fish.updateVelocity()
        }
    }
    
    func updateSprites() {
        for fish in allFish {
            fish.position = fish.position + fish.velocity
            let speed = fish.velocity.length()
            
            if speed > 0.1 && frameCount % 3 == 0 {
                let rotationValue = shortestAngleBetween(fish.zRotation, angle2: fish.velocity.angle - (π / 2))
                let rotate = SKAction.rotateByAngle(rotationValue, duration: 0.25)
                fish.removeActionForKey("rotate")
                fish.runAction(rotate, withKey: "rotate")
            }
        }
    }
    
    func restrainFish() {
        for fish in allFish {
            let newPosition = CGPoint(x: fish.position.x.clamped(ScreenMargin, size.width - ScreenMargin),
                                      y: fish.position.y.clamped(ScreenMargin, size.height - ScreenMargin))
            if newPosition != fish.position {
                if newPosition.x == ScreenMargin {
                    fish.position = CGPoint(x: ScreenMargin, y: fish.position.y)
                    fish.velocity = CGPoint(angle: 0) * StartingSpeed
                } else if newPosition.x == size.width - ScreenMargin {
                    fish.position = CGPoint(x: size.width - ScreenMargin, y: fish.position.y)
                    fish.velocity = CGPoint(angle: π) * StartingSpeed
                } else if newPosition.y == ScreenMargin {
                    fish.position = CGPoint(x: fish.position.x, y: ScreenMargin)
                    fish.velocity = CGPoint(angle: π/2) * StartingSpeed
                } else {
                    fish.position = CGPoint(x: fish.position.x, y: size.height - ScreenMargin)
                    fish.velocity = CGPoint(angle: -π/2) * StartingSpeed
                }
            }
        }
    }
}

extension PondScene: FishDelegate {
    func fishPositions(within distance: CGFloat, of fish: Fish) -> [CGPoint] {
        var positions = [CGPoint]()
        for otherFish in allFish {
            let distanceTo = fish.position.distanceTo(otherFish.position)
            if distanceTo < distance && otherFish !== fish {
                positions.append(otherFish.position)
                let requiredDistance: CGFloat = fish.separationDistance
                if distanceTo < requiredDistance {
                    let angle = (otherFish.position - fish.position).angle
                    positions.append(fish.position + CGPoint(angle: angle) * requiredDistance)
                } else {
                    positions.append(otherFish.position)
                }
            }
        }
        return positions
    }
    
    func fishVelocities(within distance: CGFloat, of fish: Fish) -> [CGPoint] {
        var velocities = [CGPoint]()
        for otherFish in allFish {
            let distanceTo = fish.position.distanceTo(otherFish.position)
            if distanceTo < distance && otherFish !== fish {
                velocities.append(otherFish.velocity)
            }
        }
        return velocities
    }
    
    func foodLocation() -> CGPoint? {
        return foodParticles?.position
    }
    
    func rippleLocation() -> CGPoint? {
        return ripple?.position
    }
}

protocol FishDelegate {
    func fishPositions(within distance: CGFloat, of fish: Fish) -> [CGPoint]
    func fishVelocities(within distance: CGFloat, of fish: Fish) -> [CGPoint]
    func foodLocation() -> CGPoint?
    func rippleLocation() -> CGPoint?
}
