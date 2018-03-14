//
//  SolarSystemScene.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class SolarSystemScene {
    
    class func createSolarSystem(at point: SCNVector3) -> SCNNode {
        let insertionYOffset = Float(0.5)
        let hitResultPosition = SCNVector3Make(point.x,
                                               point.y + insertionYOffset,
                                               point.z)
        
        //insertOmniLight(at: hitResultPosition)
        
        // MARK: - SUN
        let sunMaterial = SCNMaterial()
        sunMaterial.lightingModel = SCNMaterial.LightingModel.physicallyBased
        sunMaterial.emission.contents = UIImage(named: "sun")
        
        let sunGeometry = SCNSphere(radius: 0.25)
        sunGeometry.materials = [sunMaterial]
        
        let sunNode = SCNNode(geometry: sunGeometry)
        sunNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        sunNode.position = hitResultPosition
        sunNode.physicsBody?.mass = 0.0
        sunNode.physicsBody?.categoryBitMask = CollisionCategory.sphere.rawValue
        
        //self.sceneView.scene.rootNode.addChildNode(sunNode)
        
        // MARK: - EARTH
        // Clouds
        let cloudsMaterial = SCNMaterial()
        cloudsMaterial.lightingModel = SCNMaterial.LightingModel.physicallyBased
        cloudsMaterial.transparent.contents = UIImage(named: "earth_clouds")
        cloudsMaterial.transparencyMode = .rgbZero
        cloudsMaterial.diffuse.contents = UIColor.white
        
        let cloudsSphereGeometry = SCNSphere(radius: 0.1)
        cloudsSphereGeometry.materials = [cloudsMaterial]
        
        let cloudsSphereNode = SCNNode(geometry: cloudsSphereGeometry)
        
        // Earth Surface
        let earthMaterial = SCNMaterial()
        earthMaterial.lightingModel = SCNMaterial.LightingModel.physicallyBased
        earthMaterial.diffuse.contents = UIImage(named: "earth")
        earthMaterial.specular.contents = UIImage(named: "earth_specular_map")
        earthMaterial.normal.contents = UIImage(named: "earth_normal_map")
        
        let emissionTexture = UIImage(named: "earth_nightmap")!
        let emission = SCNMaterialProperty(contents: emissionTexture)
        earthMaterial.setValue(emission, forKey: "emissionTexture")
        
        // We can use _lightingContribution.diffuse (RGB (vec3) color representing lights that are applied to the diffuse)
        // to determine areas of an object (in this case - Earth) that are illuminated
        // and then use it to mask the emission texture in the fragment shader modifier.
        // 1. calculate luminance of the _lightingContribution.diffuse color (in case the lighting is not pure white)
        // 2. subtract it from one to get luminance of the "dark side"
        // 3. get emission from a custom texture using diffuse UV coordinates (granted emission and diffuse textures have the same ones) and apply luminance to it by multiplication
        // 4. Add it to the final output color (the same way regular emission is applied)
        let shaderModifier =
        """
        uniform sampler2D emissionTexture;

        vec3 light = _lightingContribution.diffuse;
        float lum = max(0.0, 1 - (0.2126*light.r + 0.7152*light.g + 0.0722*light.b));
        vec4 emission = texture2D(emissionTexture, _surface.diffuseTexcoord) * lum;
        _output.color += emission;
        """
        earthMaterial.shaderModifiers = [.fragment: shaderModifier]
        
        let earthGeometry = SCNSphere(radius: 0.1)
        earthGeometry.materials = [earthMaterial]
        
        let earthNode = SCNNode(geometry: earthGeometry)
        earthNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        earthNode.position = SCNVector3Make(sunNode.position.x + 0.7, sunNode.position.y, sunNode.position.z)
        earthNode.physicsBody?.mass = 0.0
        earthNode.physicsBody?.categoryBitMask = CollisionCategory.sphere.rawValue
        earthNode.addChildNode(cloudsSphereNode)
        
        // Rotate around self orbit
        let spinAnimation = CABasicAnimation(keyPath: "rotation")
        spinAnimation.fromValue = NSValue.init(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        spinAnimation.toValue = NSValue.init(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * Float.pi)))
        spinAnimation.duration = 40
        spinAnimation.repeatCount = Float.infinity
        earthNode.addAnimation(spinAnimation, forKey: "ZAxisRotation")
        
        // Rotate around some point with radius 0.05
        let earthRotationAroundStar = SCNAction.rotateBy(x: 0, y: 3, z: 0, duration: 120)
        let earthInfRotationAroundStar = SCNAction.repeatForever(earthRotationAroundStar)
        let earthRotationAroundStarHelperNode = SCNNode()
        earthRotationAroundStarHelperNode.position = hitResultPosition
        earthRotationAroundStarHelperNode.addChildNode(earthNode)
        earthRotationAroundStarHelperNode.runAction(earthInfRotationAroundStar)
        
        // MARK: - MOON
        let moonMaterial = SCNMaterial()
        moonMaterial.diffuse.contents = UIImage(named: "moon")
        
        let moonGeometry = SCNSphere(radius: 0.05)
        moonGeometry.materials = [moonMaterial]
        
        let moonNode = SCNNode(geometry: moonGeometry)
        moonNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        moonNode.position = SCNVector3Make(0.3, 0, 0)
        moonNode.physicsBody?.mass = 0.0
        moonNode.physicsBody?.categoryBitMask = CollisionCategory.sphere.rawValue
        
        // Rotate moon around self-orbit
        let moonSpinAnimation = CABasicAnimation(keyPath: "rotation")
        moonSpinAnimation.fromValue = NSValue.init(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: 0))
        moonSpinAnimation.toValue = NSValue.init(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2 * Float.pi)))
        moonSpinAnimation.duration = 50
        moonSpinAnimation.repeatCount = Float.infinity
        moonNode.addAnimation(moonSpinAnimation, forKey: "ZAxisRotation")
        
        // Helper node to rotate moon coordinate system around earth
        let moonRotationAroundEarth = SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 1)
        let moonInfRotationAroundEarth = SCNAction.repeatForever(moonRotationAroundEarth)
        let moonRotationAroundEarthHelperNode = SCNNode()
        moonRotationAroundEarthHelperNode.position = SCNVector3Make(0, 0, 0)
        moonRotationAroundEarthHelperNode.addChildNode(moonNode)
        moonRotationAroundEarthHelperNode.runAction(moonInfRotationAroundEarth)
        
        earthNode.addChildNode(moonRotationAroundEarthHelperNode)
        
        // MARK: - Result
        
        let compoundNode = SCNNode()
        compoundNode.addChildNode(sunNode)
        compoundNode.addChildNode(earthRotationAroundStarHelperNode)
        return compoundNode
        //self.sceneView.scene.rootNode.addChildNode(sphereRotationAroundStarHelperNode)
    }
}
