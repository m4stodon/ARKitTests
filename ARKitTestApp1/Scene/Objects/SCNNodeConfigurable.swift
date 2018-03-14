//
//  SCNNodeConfigurable.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/21/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

extension SCNNode: ConfigActionTarget {
    
    func dimensions() -> SCNVector3 {
        let vector = self.boundingBox.max
        return vector
    }
    
    func changeMaterial() {
        print("changeMaterial")
        let material = SCNMaterial()
        material.lightingModel = SCNMaterial.LightingModel.physicallyBased
        material.diffuse.contents = UIColor.random()
        geometry?.replaceMaterial(at: 0, with: material)
    }
    
    func transform() {
        print("transfrom")
    }
    
    func remove() {
        print("remove")
        removeFromParentNode()
    }
    
}
