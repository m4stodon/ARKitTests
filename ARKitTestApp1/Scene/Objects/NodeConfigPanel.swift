//
//  SettingsMenuObject.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit


protocol ConfigActionTarget: class {
    func dimensions() -> SCNVector3
    func changeMaterial()
    func transform()
    func remove()
}

protocol ConfigPanelController: class {
    func configPanelDidDisappear()
}

class NodeConfigPanelViewAction {
    let title: String!
    init(title: String) {
        self.title = title
    }
}

class NodeConfigPanelView: SKScene {
    
    var actions: [NodeConfigPanelViewAction]? = nil
    
    init(with actions: [NodeConfigPanelViewAction]) {
        self.actions = actions
        
        let height = 300
        let width = 200
        let actionDelta = CGFloat(height / actions.count)
        let actionInitialPoint = CGPoint(x: CGFloat(width / 2), y: CGFloat(height / actions.count / 2))
        let separatorDelta = CGFloat(height / actions.count / 2)
        let separatorInitialPoint = CGPoint(x: CGFloat(0), y: CGFloat(height / actions.count))
        
        super.init(size: CGSize(width: width, height: height))//actions.count * 40))
        self.backgroundColor = UIColor.clear
        
        // Setup body
        let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: 0)
        rectangle.fillColor = #colorLiteral(red: 0.9669261864, green: 1, blue: 0.946137909, alpha: 1)
        rectangle.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        rectangle.lineWidth = 4
        rectangle.alpha = 0.6
        addChild(rectangle)
        
        //let image = SKTexture(image: UIImage(named: "del-rey")!)
        //let imageNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 500, height: 785), cornerRadius: 0)
        //imageNode.fillTexture = image
        //imageNode.fillColor = UIColor.white
        //imageNode.zRotation = CGFloat.pi
        //imageNode.run(SKAction.rotate(byAngle: .pi/2, duration: 0.2))
        //skScene.addChild(imageNode)
        
        var lastActionPosition = actionInitialPoint
        var lastSeparatorPosition = separatorInitialPoint
        
        for action in actions {
            // Add action
            let labelNode = SKLabelNode(text: action.title)
            labelNode.fontSize = 26
            //labelNode.fontName = "SanFranciscoDisplay-Bold"
            labelNode.numberOfLines = 2
            labelNode.position = lastActionPosition
            labelNode.zRotation = CGFloat.pi
            labelNode.fontName = "AvenirNextCondensed-DemiBold"
            labelNode.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            addChild(labelNode)
            
            // Add separator
            let separator = SKShapeNode(rect: CGRect(x: 15, y: 0, width: 170, height: 1), cornerRadius: 0)
            separator.fillColor = #colorLiteral(red: 0.5247693062, green: 0.5247693062, blue: 0.5247693062, alpha: 1)
            separator.strokeColor = #colorLiteral(red: 0.5247693062, green: 0.5247693062, blue: 0.5247693062, alpha: 1)
            separator.lineWidth = 0.5
            separator.alpha = 0.4
            separator.position = lastSeparatorPosition
            addChild(separator)
            
            // Update positioning
            lastActionPosition = CGPoint(x: CGFloat(width / 2), y: lastActionPosition.y + actionDelta)
            lastSeparatorPosition = CGPoint(x: 0, y: lastActionPosition.y + separatorDelta)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class NodeConfigPanel: SCNNode {
    
    weak var configPanelController: ConfigPanelController? = nil
    
    weak var actionTarget: ConfigActionTarget? = nil
    
    init(for hitResult: SCNHitTestResult) {
        super.init()
    
        let hitResultPosition = SCNVector3Make(hitResult.worldCoordinates.x,
                                               hitResult.worldCoordinates.y + 0.2,
                                               hitResult.worldCoordinates.z)
    
        let skScene = NodeConfigPanelView(with: [
            NodeConfigPanelViewAction(title: "Change Material"),
            NodeConfigPanelViewAction(title: "Remove"),
            NodeConfigPanelViewAction(title: "Cancel")])
        
        let material = SCNMaterial()
        material.diffuse.contents = skScene
        material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(-1, 1, 1), 1, 0, 0) // flip horizontally
        //material.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0) // flip vertically
        
        let planeGeometry = SCNBox(width: 0.2, height: 0.3, length: 0.01, chamferRadius: 0.1)
        planeGeometry.materials = [material]
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [SCNBillboardAxis.Y]
        
        self.geometry = planeGeometry
        self.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.dynamic, shape: nil)
        self.position = hitResultPosition
        self.physicsBody?.mass = 0.0
        self.physicsBody?.categoryBitMask = CollisionCategory.plane.rawValue
        self.constraints = [billboardConstraint]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func handleTap(at position: SCNVector3) {
        let topBoundry = self.worldPosition.y + 0.15
        let bottomBoundry = self.worldPosition.y - 0.15
        if position.y <= topBoundry && position.y >= bottomBoundry {
            if position.y < self.worldPosition.y - 0.15 + 0.1 {
                print("HIT 3")
                removeFromParentNode()
                configPanelController?.configPanelDidDisappear()
            } else if position.y < self.worldPosition.y - 0.15 + 0.1 * 2 {
                print("HIT 2")
                actionTarget?.remove()
                removeFromParentNode()
                configPanelController?.configPanelDidDisappear()
            } else if position.y < self.worldPosition.y - 0.15 + 0.1 * 3 {
                print("HIT 1")
                removeFromParentNode()
                actionTarget?.changeMaterial()
                configPanelController?.configPanelDidDisappear()
            } else {
                print("UNRECOGNIZED")
                removeFromParentNode()
                configPanelController?.configPanelDidDisappear()
            }
        }
    }
}


