//
//  ARKitSceneViewController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/9/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARKitSceneViewController: UIViewController {
    
    var controller:
    
    @IBOutlet var sceneView: ARSCNView!
    var coordinatePlanes = Dictionary<UUID, CoordinatePlane>()
    
    var planes = Array<SCNNode>()
    var boxes = Array<SCNNode>()
    var spheres = Array<SCNNode>()
    var spotLights = Array<SCNNode>()
    var ambientLights = Array<SCNNode>()
    var omniLights = Array<SCNNode>()
    var directionalLights = Array<SCNNode>()
    var objectConfigMenuIsShown: Bool = false
    var panel: NodeConfigPanel? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // SETUP SCENE
        let scene = SCNScene() // let scene = SCNScene(named: "art.scnassets/Scorpion.scn")! // 
        self.sceneView.scene = scene
        self.sceneView.delegate = self
        // Show texture feature points, and XYZ coordinates start point
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        
        // SETUP LIGHTS
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        //insertAmbientLight()
        //insertOmniLight(at: SCNVector3Make(0, 100, 30))
        
        
        // SETUP GESTURE RECOGNIZERS
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongTap))
        longTapGestureRecognizer.minimumPressDuration = 1
        self.view.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    fileprivate func setupARKitSession() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Start detecting horizontal planes
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        
        // Start detecting light intensity
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupARKitSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Gestures
    
    @objc func handleTap(from recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: self.sceneView)
        let results = self.sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        if results.count > 0 {
            let hitResult = results.first!
            let vector = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            
            //print(results)
            //print(vector)
            let box = SceneObjectFactory.cube(at: vector)
            self.sceneView.scene.rootNode.addChildNode(box)
            self.boxes.append(box)
            //self.insertSphere(at: vector)
            //self.createSolarSystem(for: hitResult)
        }
        let sceneResults = sceneView.hitTest(tapPoint, options: nil)
        if sceneResults.count > 0 {
            let sceneHitResult = sceneResults.first!
            if sceneHitResult.node == panel {
                let vector = SCNVector3Make(sceneHitResult.worldCoordinates.x, sceneHitResult.worldCoordinates.y, sceneHitResult.worldCoordinates.z)
                panel?.handleTap(at: vector)
            }
        }
    }
    
    @objc func handleLongTap(from recognizer: UILongPressGestureRecognizer) {
        let tapPoint = recognizer.location(in: self.sceneView)
        //let results = self.sceneView.hitTest(tapPoint, options: [SCNHitTestOption.firstFoundOnly:true]) // Look for intersecting planes with tap
        let results = self.sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlane) // Look for intersecting planes with tap
        guard results.count > 0 else { return }
        let hitResult = results.first!
        //let vector = SCNVector3Make(hitResult.worldCoordinates.x, hitResult.worldCoordinates.y, hitResult.worldCoordinates.z)
        //let vector = SCNVector3Make(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        let sceneResults = sceneView.hitTest(tapPoint, options: nil)
        if sceneResults.count > 0 {
            //print(sceneResults)
            for sceneResult in sceneResults {
                for box in boxes {
                    if sceneResult.node == box {
                        let vector = SCNVector3Make(sceneResult.worldCoordinates.x, sceneResult.worldCoordinates.y, sceneResult.worldCoordinates.z)
                        self.showConfigPanel(at: vector, for: sceneResults.first!.node)
                        return
                    }
                }
            }
        }
    }
    
    @IBAction func planeDetectionSwitch(_ sender: UISwitch) {
        var worldTrackingConfiguration = ARWorldTrackingConfiguration.PlaneDetection.init(rawValue: 0) // Doesnt track
        if sender.isOn {
            worldTrackingConfiguration = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        }
        let configuration = self.sceneView.session.configuration as! ARWorldTrackingConfiguration
        configuration.planeDetection = worldTrackingConfiguration
        sceneView.session.run(configuration)
    }
    
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    
    // Override to create and configure nodes for anchors added to the view's session.
    //    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
    //        let node = SCNNode()
    //        return node
    //    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        let planeNode = CoordinatePlane(with: anchor as! ARPlaneAnchor)
        coordinatePlanes[anchor.identifier] = planeNode
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // See if this is a plane we are currently rendering
        let plane = self.coordinatePlanes[anchor.identifier]
        guard plane != nil else { return }
        plane?.update(with: anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate else { return }
        //handleLightIntensity(estimate: lightEstimate)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.coordinatePlanes[anchor.identifier] = nil
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// MARK: - Custom SCNNodes

extension ViewController: ConfigPanelController {
    
    func configPanelDidDisappear() {
        self.panel = nil
        self.objectConfigMenuIsShown = false
    }
    
    func handleLightIntensity(estimate: ARLightEstimate) {
        let intensity = estimate.ambientIntensity / 1000.0
        // self.sceneView.scene.lightingEnvironment.intensity = intensity
        SCNTransaction.begin()
        for light in omniLights {
            if light.name == "OmniLightNode" {
                let colorNew = UIColor(red: intensity/1.0, green: intensity/1.0, blue: intensity/1.0, alpha: 1.0)
                light.light?.color = colorNew
            }
        }
        SCNTransaction.commit()
        print("Handling light intensity: ", estimate.ambientIntensity)
    }
    
    func showConfigPanel(at position: SCNVector3, for node: ConfigActionTarget) {
        guard objectConfigMenuIsShown == false else { return }
        let panel = NodeConfigPanel(at: position)
        self.sceneView.scene.rootNode.addChildNode(panel)
        self.objectConfigMenuIsShown = true
        self.panel = panel
        self.panel?.actionTarget = node
        self.panel?.configPanelController = self
        print("Config Panel World Position: ", panel.worldPosition)
    }
    
}
