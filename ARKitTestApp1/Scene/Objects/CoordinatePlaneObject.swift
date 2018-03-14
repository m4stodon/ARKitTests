//
//  CoordinatePlaneObject.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import ARKit

class CoordinatePlane: SCNNode {
    
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNBox!
    
    init(with anchor: ARPlaneAnchor) {
        super.init()
        
        self.anchor = anchor;
        let width = CGFloat(anchor.extent.x)
        let length = CGFloat(anchor.extent.z)
        let planeHeight = CGFloat(0.001)
        
        // Create geometry
        self.planeGeometry = SCNBox(width: width, height: planeHeight, length: length, chamferRadius: 0)
        let material = SCNMaterial()
        let planeGridImage = UIImage.init(named: "grid")
        material.diffuse.contents = planeGridImage
        
        // Since we are using a cube, we only want to render the tron grid
        // on the top face, make the other sides transparent
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.clear
        planeGeometry.materials = [ transparentMaterial,
                                    transparentMaterial,
                                    transparentMaterial,
                                    transparentMaterial,
                                    material, //top side of SCNBox geometry
            transparentMaterial]
        
        // Create plane subnode object
        let planeNode = SCNNode(geometry: planeGeometry)
        // Since our plane has some height, move it down to be at the actual surface
        planeNode.position = SCNVector3Make(0, Float(-planeHeight / 2), 0);
        // Give the plane a physics body so that items we add to the scene interact with it
        planeNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
        // Setup node
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(with anchor: ARPlaneAnchor) {
        // As the user moves around the extend and location of the plane
        // may be updated. We need to update our 3D geometry to match the
        // new parameters of the plane.
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.length = CGFloat(anchor.extent.z)
        
        // When the plane is first created it's center is 0,0,0 and the nodes
        // transform contains the translation parameters. As the plane is updated
        // the planes translation remains the same but it's center is updated so
        // we need to update the 3D geometry position
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        let node = childNodes.first
        node?.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        setTextureScale()
    }
    
    func setTextureScale() {
        let width = Float(planeGeometry.width)
        let length = Float(planeGeometry.length)
        
        // As the width/height of the plane updates, we want our tron grid material to
        // cover the entire plane, repeating the texture over and over. Also if the
        // grid is less than 1 unit, we don't want to squash the texture to fit, so
        // scaling updates the texture co-ordinates to crop the texture in that case
        let material = planeGeometry.materials.first
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, length, 1)
        material?.diffuse.wrapS = SCNWrapMode.repeat
        material?.diffuse.wrapT = SCNWrapMode.repeat
    }
    
}
