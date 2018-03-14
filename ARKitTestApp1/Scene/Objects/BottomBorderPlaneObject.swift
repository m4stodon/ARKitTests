//
//  SceneBorderCatcherObject.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class SceneBorderCatcherObject: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(with anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor;
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        let planeHeight = CGFloat(0.001)
        
        
        
        let floorGeometry = SCNBox(width: 1000, height: 1000, length: 1000, chamferRadius: 0)
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.clear
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3Make(0, -10, 0) // Place below the worl to catch all falling nodes
        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: nil)
        floorNode.physicsBody?.collisionBitMask = CollisionCategory.sphere.rawValue
        floorNode.physicsBody?.contactTestBitMask = CollisionCategory.cube.rawValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

