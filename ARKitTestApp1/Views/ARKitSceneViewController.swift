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

protocol ARKitSceneViewControllerActionHandler {
    func handleTap(at point: CGPoint)
    func handleLongTap(at point: CGPoint)
}

protocol ARKitSceneViewControllerInterface: class {
    var sceneView: ARSCNView {
        get
    }
    func enablePlaneDetection()
    func disablePlaneDetection()
    func add(node: SCNNode)
    func addButton(action: @escaping (()->()))
    func dismissView()
}

class ARKitSceneViewController
    : UIViewController
    , ARKitSceneViewControllerInterface
    , ARSCNViewDelegate
{

    // private
    var actionHandler: ARKitSceneViewControllerActionHandler? = nil
    var arKitSceneView: ARSCNView!
    var planeDetectionSwitch: UISwitch!
    var actionButton: UIButton!
    
    var coordinatePlanes = Dictionary<UUID, CoordinatePlane>()
    var planes = Array<SCNNode>()
    var boxes = Array<SCNNode>()
    var spheres = Array<SCNNode>()
    var spotLights = Array<SCNNode>()
    var ambientLights = Array<SCNNode>()
    var omniLights = Array<SCNNode>()
    var directionalLights = Array<SCNNode>()
    
    // MARK: - ARKitSceneViewControllerInterface
    
    var sceneView: ARSCNView {
        return arKitSceneView
    }
    
    func enablePlaneDetection() {
        planeDetection(enable: true)
    }
    
    func disablePlaneDetection() {
        planeDetection(enable: false)
    }
    
    func add(node: SCNNode) {
        print(arKitSceneView.scene.rootNode)
        arKitSceneView.scene.rootNode.addChildNode(node)
    }
    
    var actionButtonEventHandlerBlock: (()->())!
    func addButton(action: @escaping (() -> ())) {
        setupActionButton()
        actionButtonEventHandlerBlock = action
        actionButton.addTarget(self, action: #selector(ARKitSceneViewController.callActionBlock), for: UIControlEvents.touchUpInside)
    }
    @objc private func callActionBlock() {
        actionButtonEventHandlerBlock()
    }
    
    @objc func dismissView() {
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupPlaneDetectSwitch()
        setupDismissButton()
        setupScene()
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupARKitSession()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arKitSceneView.session.pause()
    }
    
    // MARK: - Private Setups
    
    private func setupSceneView() {
        arKitSceneView = ARSCNView()
        view.addSubview(arKitSceneView)
        
        arKitSceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: arKitSceneView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: arKitSceneView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: arKitSceneView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: arKitSceneView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            ])
    }
    
    private func setupPlaneDetectSwitch() {
        planeDetectionSwitch = UISwitch()
        planeDetectionSwitch.isOn = true
        planeDetectionSwitch.addTarget(self, action: #selector(ARKitSceneViewController.planeDetectionSwitch(_:)), for: UIControlEvents.valueChanged)
        view.addSubview(planeDetectionSwitch)
        
        planeDetectionSwitch.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: planeDetectionSwitch, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 16),
            NSLayoutConstraint(item: planeDetectionSwitch, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -16)
            ])
    }
    
    private func setupActionButton() {
        actionButton = UIButton()
        actionButton.setTitle("Action", for: UIControlState.normal)
        actionButton.backgroundColor = UIColor.red
        view.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: actionButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100),
            NSLayoutConstraint(item: actionButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: actionButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -16),
            NSLayoutConstraint(item: actionButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)
            ])
    }
    
    private func setupDismissButton() {
        let dismissButton = UIButton()
        dismissButton.setImage(UIImage(named: "back"), for: UIControlState.normal)
        dismissButton.addTarget(self, action: #selector(ARKitSceneViewController.dismissView), for: UIControlEvents.touchUpInside)
        view.addSubview(dismissButton)
        
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            NSLayoutConstraint(item: dismissButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44),
            NSLayoutConstraint(item: dismissButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: dismissButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: dismissButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)
            ])
    }
    
    private func setupScene() {
        // SETUP SCENE
        let scene = SCNScene() // let scene = SCNScene(named: "art.scnassets/Scorpion.scn")! //
        arKitSceneView.scene = scene
        arKitSceneView.delegate = self
        // Show texture feature points, and XYZ coordinates start point
        arKitSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // SETUP LIGHTS
        arKitSceneView.autoenablesDefaultLighting = true
        arKitSceneView.automaticallyUpdatesLighting = true
        //insertAmbientLight()
        //insertOmniLight(at: SCNVector3Make(0, 100, 30))
    }
    
    private func setupGestures() {
        // SETUP GESTURE RECOGNIZERS
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARKitSceneViewController.handleTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ARKitSceneViewController.handleLongTap))
        longTapGestureRecognizer.minimumPressDuration = 1
        self.view.addGestureRecognizer(longTapGestureRecognizer)
    }
    
    private func setupARKitSession() {
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Start detecting horizontal planes
        configuration.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        
        // Start detecting light intensity
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        arKitSceneView.session.run(configuration)
    }
    
    // MARK: - Gestures
    
    @objc private func handleTap(from recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: arKitSceneView)
        actionHandler?.handleTap(at: tapPoint)
    }
    
    @objc private func handleLongTap(from recognizer: UILongPressGestureRecognizer) {
        let tapPoint = recognizer.location(in: arKitSceneView)
        actionHandler?.handleLongTap(at: tapPoint)
    }
    
    // MARK: - Actions
    
    @objc private func planeDetectionSwitch(_ sender: UISwitch) {
        planeDetection(enable: planeDetectionSwitch.isOn)
    }
    
    private func planeDetection(enable: Bool) {
        
        var worldTrackingConfiguration: ARWorldTrackingConfiguration.PlaneDetection
        
        if enable == true {
            worldTrackingConfiguration = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        } else {
            worldTrackingConfiguration = ARWorldTrackingConfiguration.PlaneDetection.init(rawValue: 0) // Doesnt track
        }
        
        let configuration = arKitSceneView.session.configuration as! ARWorldTrackingConfiguration
        configuration.planeDetection = worldTrackingConfiguration
        arKitSceneView.session.run(configuration)
    }
    
    // MARK: - ARSCNViewDelegate
    
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
        //guard let lightEstimate = arKitSceneView.session.currentFrame?.lightEstimate else { return }
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
