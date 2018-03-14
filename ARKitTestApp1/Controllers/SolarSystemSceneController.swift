//
//  SolarSystemSceneController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/22/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class SolarSystemSceneController: ARKitSceneViewControllerActionHandler {
    
    weak var view: ARKitSceneViewControllerInterface!
    
    func handleTap(at point: CGPoint) {
        
        let results = view.sceneView.hitTest(point, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        if results.count > 0 {
            let hitResult = results.first!
            let vector = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            DispatchQueue.global().async { [weak self] in
                let solarSystem = SolarSystemScene.createSolarSystem(at: vector)
                DispatchQueue.main.async {
                    self?.view.add(node: solarSystem)
                }
            }
        }
        
    }
    
    func handleLongTap(at point: CGPoint) {
        // DO nothing
    }
    
}
