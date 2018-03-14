//
//  ComputerVisionSceneController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/22/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit
import Vision

class ComputerVisionSceneController: ARKitSceneViewControllerActionHandler {

    weak var view: ARKitSceneViewControllerInterface!
    
    // MARK: - ARKitSceneViewControllerActionHandler
    
    func handleTap(at point: CGPoint) {
        // Do nothing
    }
    
    func handleLongTap(at point: CGPoint) {
        // Do nothing
    }
    
    // MARK: - Actions
    
    func recognizeObject() {
        DispatchQueue.global(qos: .background).async {
            do {
                let model = try VNCoreMLModel(for: Inceptionv3().model)
                let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                    DispatchQueue.main.async {
                        // Access the first result in the array after casting the array as a VNClassificationObservation array
                        guard let results = request.results as? [VNClassificationObservation], let result = results.first else {
                            print ("No results?")
                            return
                        }
                        
                        // Create a transform with a translation of 0.4 meters in front of the camera
                        var translation = matrix_identity_float4x4
                        translation.columns.3.z = -0.4
                        let transform = simd_mul(self.view.sceneView.session.currentFrame!.camera.transform, translation)
                        
                        // Add label for detected object
                        let material = SCNMaterial()
                        material.diffuse.contents = UIColor.random()
                        material.isDoubleSided = false
                        
                        let labelGeometry = SCNText()
                        labelGeometry.string = result.identifier
                        labelGeometry.extrusionDepth = 0.02
                        labelGeometry.font = UIFont.systemFont(ofSize: 1)
                        labelGeometry.materials = [material]

                        let labelNode = SCNNode(geometry: labelGeometry)
                        labelNode.scale = SCNVector3Make(0.02, 0.02, 0.02)
                        labelNode.position = SCNVector3Make(0,0,0)
                        labelNode.pivot = SCNMatrix4MakeRotation(Float.pi, 0, 1, 0);
    
                        // Update object's pivot to its center
                        let (min, max) = labelGeometry.boundingBox
                        let dx = min.x + 0.5 * (max.x - min.x)
                        let dy = min.y + 0.5 * (max.y - min.y)
                        let dz = min.z + 0.5 * (max.z - min.z)
                        labelNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
                        
                        // label node container
                        let planeGeometry = SCNPlane(width: 0.001, height: 0.001)
                        let transparentMaterial = SCNMaterial()
                        transparentMaterial.diffuse.contents = UIColor.clear
                        planeGeometry.firstMaterial = transparentMaterial
                        
                        let parentNode = SCNNode(geometry: planeGeometry)
                        
                        // apply billboard constraint to the parent node
                        let yFreeConstraint = SCNBillboardConstraint()
                        yFreeConstraint.freeAxes = .Y
                        parentNode.constraints = [yFreeConstraint]
                        
                        parentNode.position = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                        parentNode.addChildNode(labelNode)
                        
                        self.view.add(node: parentNode)
                    }
                })
                
                let handler = VNImageRequestHandler(cvPixelBuffer: self.view.sceneView.session.currentFrame!.capturedImage, options: [:])
                try handler.perform([request])
            } catch {}
        }
    }
    
}

