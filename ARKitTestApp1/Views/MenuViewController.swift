//
//  MenuViewController.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/28/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import UIKit

protocol MenuViewControllerInterface: class {
    func present(viewController: UIViewController)
}

class MenuViewController
    : UIViewController
    , MenuViewControllerInterface
{
    
    var controller: MenuControllerInterface!
    
    @IBOutlet weak var solarSystemExampleButton: UIButton!
    @IBOutlet weak var configurableObjectsExampleButton: UIButton!
    @IBOutlet weak var coreMLVisionExampleButton: UIButton!
    
    @IBAction func showSolarSystemExample(_ sender: UIButton) {
        controller.showSolarSystemExample()
    }
    
    @IBAction func showConfigurableObjectsExample(_ sender: UIButton) {
        controller.showConfigurableObjectsExample()
    }
    
    @IBAction func showCoreMLVisionExample(_ sender: UIButton) {
        controller.showCoreMLVisionExample()
    }
    
    func present(viewController: UIViewController) {
        if self.navigationController == nil {
            self.present(viewController, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewBackgroundColor = makeGradient(for: CGSize(width: self.view.bounds.width, height: self.view.bounds.height), with: [#colorLiteral(red: 0.07843137255, green: 0.1176470588, blue: 0.1882352941, alpha: 1), #colorLiteral(red: 0.1411764706, green: 0.231372549, blue: 0.3333333333, alpha: 1)], alpha: 1.0)
        
        self.view.backgroundColor = viewBackgroundColor
        
        solarSystemExampleButton.layer.cornerRadius = 10.0
        configurableObjectsExampleButton.layer.cornerRadius = 10.0
        coreMLVisionExampleButton.layer.cornerRadius = 10.0
        
        solarSystemExampleButton.layer.borderWidth = 1.0
        configurableObjectsExampleButton.layer.borderWidth = 1.0
        coreMLVisionExampleButton.layer.borderWidth = 1.0
        
        solarSystemExampleButton.layer.borderWidth = 1.0
        configurableObjectsExampleButton.layer.borderWidth = 1.0
        coreMLVisionExampleButton.layer.borderWidth = 1.0
        
        solarSystemExampleButton.backgroundColor = #colorLiteral(red: 0.3490196078, green: 0.4, blue: 0.4862745098, alpha: 1)
        configurableObjectsExampleButton.backgroundColor = #colorLiteral(red: 0.3490196078, green: 0.4, blue: 0.4862745098, alpha: 1)
        coreMLVisionExampleButton.backgroundColor = #colorLiteral(red: 0.3490196078, green: 0.4, blue: 0.4862745098, alpha: 1)
        
        solarSystemExampleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        configurableObjectsExampleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        coreMLVisionExampleButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private func makeGradient(for size: CGSize, with colors: [UIColor], alpha: CGFloat) -> UIColor? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let colors = colors.map { (color: UIColor) -> CGColor in
            return color.withAlphaComponent(alpha).cgColor
        }
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: nil
            ) else { return nil }
        
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width/2, y: 0),
            end: CGPoint(x: size.width/2, y: size.height),
            options: []
        )
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return UIColor(patternImage: image)
        }
        return nil
    }
    
}
