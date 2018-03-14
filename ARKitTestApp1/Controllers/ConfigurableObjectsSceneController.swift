//
//  ConfigurableObjectsSceneController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/22/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class ConfigurableObjectsSceneController
    : ARKitSceneViewControllerActionHandler
    , ConfigPanelController
{
    
    weak var view: ARKitSceneViewControllerInterface!
    
    var boxes = Array<SCNNode>()
    var objectConfigMenuIsShown: Bool = false
    var panel: NodeConfigPanel? = nil
    
    
    // MARK: - ARKitSceneViewControllerActionHandler
    
    func handleTap(at point: CGPoint) {
        
        let sceneResults = view.sceneView.hitTest(point, options: nil)
        if sceneResults.count > 0 {
            let sceneHitResult = sceneResults.first!
            if sceneHitResult.node == panel {
                let vector = SCNVector3Make(sceneHitResult.worldCoordinates.x, sceneHitResult.worldCoordinates.y, sceneHitResult.worldCoordinates.z)
                panel?.handleTap(at: vector)
                return
            }
        }
        
        let results = view.sceneView.hitTest(point, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        if results.count > 0 {
            let hitResult = results.first!
            let vector = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            let box = SceneObjectFactory.cube(at: vector)
            view.add(node: box)
            boxes.append(box)
        }
    }
    
    func handleLongTap(at point: CGPoint) {
        //let results = arKitSceneView.hitTest(point, options: [SCNHitTestOption.firstFoundOnly:true]) // Look for intersecting planes with tap
        let results = view.sceneView.hitTest(point, types: ARHitTestResult.ResultType.existingPlane) // Look for intersecting planes with tap
        guard results.count > 0 else { return }
        //let hitResult = results.first!
        //let vector = SCNVector3Make(hitResult.worldCoordinates.x, hitResult.worldCoordinates.y, hitResult.worldCoordinates.z)
        //let vector = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        let sceneResults = view.sceneView.hitTest(point, options: nil)
        if sceneResults.count > 0 {
            //print(sceneResults)
            for sceneResult in sceneResults {
                for box in boxes {
                    if sceneResult.node == box {
                        self.showConfigPanel(for: sceneResult)
                        return
                    }
                }
            }
        }
    }
    
    
    // MARK: - Custom SCNNodes
    

    
    //func handleLightIntensity(estimate: ARLightEstimate) {
        //let intensity = estimate.ambientIntensity / 1000.0
        // arKitSceneView.scene.lightingEnvironment.intensity = intensity
        //SCNTransaction.begin()
        //for light in omniLights {
        //    if light.name == "OmniLightNode" {
        //        let colorNew = UIColor(red: intensity/1.0, green: intensity/1.0, blue: intensity/1.0, alpha: 1.0)
        //        light.light?.color = colorNew
        //    }
        //}
        //SCNTransaction.commit()
        //print("Handling light intensity: ", estimate.ambientIntensity)
    //}
    
    // MARK: - ConfigPanelController
    
    func configPanelDidDisappear() {
        self.panel = nil
        self.objectConfigMenuIsShown = false
    }
    
    func showConfigPanel(for hitResult: SCNHitTestResult) {
        guard objectConfigMenuIsShown == false else { return }
        let panel = NodeConfigPanel(for: hitResult)
        view.add(node: panel)
        self.objectConfigMenuIsShown = true
        self.panel = panel
        self.panel?.actionTarget = hitResult.node
        self.panel?.configPanelController = self
        print("Config Panel World Position: ", panel.worldPosition)
    }
    
    
}
