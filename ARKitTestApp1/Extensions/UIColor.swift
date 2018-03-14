//
//  UIColor.swift
//  ARKitTestApp1
//
//  Created by Ermac on 1/17/18.
//  Copyright © 2018 YourMac. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    class func random() -> UIColor {
        let color = UIColor(red: randomValue()/255.0, green: randomValue()/255.0, blue: randomValue()/255.0, alpha: 1)
        return color
    }
    
    private class func randomValue() -> CGFloat {
        let randomColorChannel = arc4random_uniform(255)
        return CGFloat(randomColorChannel)
    }
}
