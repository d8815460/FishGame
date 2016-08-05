//
//  Fish.swift
//  MakeSchoolOfFish
//
//  Created by Dion Larson on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import SpriteKit

let NumberOfFish: Int = 32
let StartingSpeed: CGFloat = 0.25
let MaximumSpeed: CGFloat = 1.5
let ScreenMargin: CGFloat = -25

class Fish: SKSpriteNode {
    
    var velocity: CGPoint = CGPoint.zero  //速度
    var delegate: FishDelegate!
    
    // 每條魚的使用使用三個規則來瀏覽它的環境：
    // 1.凝聚力：粘在一起
    // Cohension Constants
    let cohesionVisibleDistance: CGFloat = 160
    let cohesionWeight: CGFloat = 1000
    
    // 2.分離：避免碰撞
    // Separation Constants
    let separationDistance: CGFloat = 60
    let separationWeight: CGFloat = 200
    
    // 3.陣營：模仿鄰居
    // Alignment Constants
    let alignmentVisibleDistance: CGFloat = 160
    let alignmentWeight: CGFloat = 50
    
    // Food Constants
    let foodVisibleDistance: CGFloat = 240
    let foodWeight: CGFloat = 250
    
    // Ripple Constants
    let rippleVisibleDistance: CGFloat = 200
    let rippleWeight: CGFloat = 150
    
    // Steer towards other fish
    func calculateCohension() -> CGPoint {
        // TODO: Implement this!
        let 中心點 = delegate.fishPositions(within: cohesionVisibleDistance, of: self)
        let 至中心點的向量 = vectorToCenterPoint(of: 中心點)
        
        return 至中心點的向量/cohesionWeight
    }
    
    // Keep fish separated so they do not overlap
    // 保持魚的分離，使他們不重疊
    func calculateSeparation() -> CGPoint {
        // TODO: Implement this!
        let 分離中心點 = delegate.fishPositions(within: separationDistance, of: self)
        let 翻轉向量 = vectorToCenterPoint(of: 分離中心點)*(-1)
        
        return 翻轉向量/separationWeight
    }
    
    // Create a "hive mind" by mimicking nearby fish
    // 通過模仿魚類附近創建一個“蜂群思維”
    func calculateAlignment() -> CGPoint {
        // TODO: Implement this!
        return CGPoint(x: 0, y: 0)
    }
    
    // Head towards food (single tap) 實現糧食
    func calculateFood() -> CGPoint {
        // TODO: Implement this!
        return CGPoint(x: 0, y: 0)
    }
    
    // Scatter away from ripples (double tap) 漣漪散遠
    func calculateRipple() -> CGPoint {
        // TODO: Implement this!
        return CGPoint(x: 0, y: 0)
    }
    
    func updateVelocity() {
        // Sum up all your rules and call clampVelocity!
        let cohesion = calculateCohension()         //凝聚
        let seperation = calculateSeparation()      //分離
        let alignment = calculateAlignment()        //模仿陣營
        let food = calculateFood()                  //食物
        let ripple = calculateRipple()              //波紋
        
        velocity = sum(of: [velocity, cohesion, seperation, alignment, food, ripple])
        clampVelocity()
    }
    
    func vectorToCenterPoint(of points: [CGPoint]) -> CGPoint {
        // TODO: Implement this!
        if points.count == 0 {
            return CGPoint.zero
        }
        return vectorTo(point: average(of: points))
    }
    
    func vectorTo(point point: CGPoint) -> CGPoint {
        // TODO: Implement this!
        return point - position
    }
    
    // We implemented this for you. It takes the current velocity and makes sure
    // it is under the limit, otherwise, keeps the direction and sets to limit.
    func clampVelocity() {
        let speed = velocity.length()
        if speed > MaximumSpeed {
            velocity = velocity.normalized() * MaximumSpeed
        }
    }
}

// MARK: Math Helpers

func sum(of points: [CGPoint]) -> CGPoint {
    
    // TODO: Implement this!
    return points.reduce(CGPoint.zero, combine: +)
}

func average(of points: [CGPoint]) -> CGPoint {
    // TODO: Implement this!
    
    return sum(of: points) / CGFloat(points.count)
}
