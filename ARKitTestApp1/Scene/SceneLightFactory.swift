//
//  SceneLightFactory.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class SceneLightFactory {
    
    func spotLight(at position: SCNVector3) -> SCNNode {
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light!.type = SCNLight.LightType.spot
        spotLightNode.light!.spotInnerAngle = 45
        spotLightNode.light!.spotOuterAngle = 45
        spotLightNode.position = position
        spotLightNode.eulerAngles = SCNVector3Make(-Float.pi / 2, 0, 0)  // By default the stop light points directly down the negative z-axis, we want to shine it down so rotate 90deg around the x-axis to point it down
        spotLightNode.name = "SpotLightNode"
        return spotLightNode
    }
    
    func insertAmbientLight() -> SCNNode {
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLightNode.name = "AmbientLightNode"
        return ambientLightNode
    }
    
    func insertOmniLight(at position: SCNVector3, intensity: CGFloat = 0.0) -> SCNNode {
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light!.type = SCNLight.LightType.omni
        omniLightNode.light!.color = UIColor(white: 0.5, alpha: intensity)
        omniLightNode.position = position
        omniLightNode.name = "OmniLightNode"
        return omniLightNode
    }
    
    func insertDirectionalLight(at position: SCNVector3) -> SCNNode {
        let directionalLightNode = SCNNode()
        directionalLightNode.light! = SCNLight()
        directionalLightNode.light!.type = SCNLight.LightType.directional
        directionalLightNode.light!.color = UIColor(white: 0.8, alpha: 1.0)
        directionalLightNode.position = position
        directionalLightNode.name = "DirectionalLightNode"
        return directionalLightNode
    }
    
}
