//
//  MenuController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/28/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import UIKit

protocol MenuControllerInterface {
    func showSolarSystemExample()
    func showConfigurableObjectsExample()
    func showCoreMLVisionExample()
}

class MenuController
    : MenuControllerInterface
{
    
    weak var viewController: MenuViewControllerInterface!
    
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    private func initExampleViewController() -> ARKitSceneViewController {
        let view = storyboard.instantiateViewController(withIdentifier: "ARKitSceneViewController") as! ARKitSceneViewController
        return view
    }
    
    func showSolarSystemExample() {
        let controller = SolarSystemSceneController()
        let view = initExampleViewController()
        view.actionHandler = controller
        controller.view = view
        viewController.present(viewController: view)
    }
    
    func showConfigurableObjectsExample() {
        let controller = ConfigurableObjectsSceneController()
        let view = initExampleViewController()
        view.actionHandler = controller
        controller.view = view
        viewController.present(viewController: view)
    }
    
    func showCoreMLVisionExample() {
        let controller = ComputerVisionSceneController()
        let view = initExampleViewController()
        view.actionHandler = controller
        controller.view = view
        view.addButton(action: controller.recognizeObject)
        viewController.present(viewController: view)
    }
    

    
}
