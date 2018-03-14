//
//  SceneObjectFactory.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

enum CollisionCategory: Int {
    case plane = 0
    case sphere = 1
    case cube = 2
}

class SceneObjectFactory {
    
    class func plane(at position: SCNVector3) -> SCNNode {
        
        let insertionYOffset = Float(0.5)
        let hitResultPosition = SCNVector3Make(position.x,
                                               position.y + insertionYOffset,
                                               position.z)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.random()

        let planeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.01, chamferRadius: 0)
        planeGeometry.materials = [material]

        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        planeNode.position = hitResultPosition
        planeNode.physicsBody?.mass = 0.0
        planeNode.physicsBody?.categoryBitMask = CollisionCategory.plane.rawValue
        
        return planeNode
    }
    
    class func cube(at position: SCNVector3) -> SCNNode {
        
        let insertionYOffset = Float(0.5)
        let hitResultPosition = SCNVector3Make(position.x,
                                               position.y + insertionYOffset,
                                               position.z)
        
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.physicallyBased
        material.diffuse.contents = UIColor.random()
        
        let dimension = CGFloat(0.1)
        let cubeGeometry = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        cubeGeometry.materials = [material]
        
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        cubeNode.position = hitResultPosition
        cubeNode.physicsBody?.mass = 1.0
        cubeNode.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        
        return cubeNode
    }
    
    class func sphere(at position: SCNVector3) -> SCNNode {
        let insertionYOffset = Float(0.5)
        let hitResultPosition = SCNVector3Make(position.x,
                                               position.y + insertionYOffset,
                                               position.z)
        
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.physicallyBased
        material.diffuse.contents = UIColor.random()
        
        let dimension = CGFloat(0.1)
        let sphereGeometry = SCNSphere(radius: dimension)
        sphereGeometry.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        sphereNode.position = hitResultPosition
        sphereNode.physicsBody?.mass = 1.0
        sphereNode.physicsBody?.categoryBitMask = CollisionCategory.sphere.rawValue
        
        return sphereNode
    }
}
