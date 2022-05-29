//
//  UIColor+Extension.swift
//  IB-FinantialTimeline-iOS_Example
//
//  Created by Hernán Villamil on 17/07/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    @nonobjc class var primary: UIColor {
        return UIColor(red: 236.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    @nonobjc class var greyishBrown: UIColor {
        return UIColor(white: 68.0 / 255.0, alpha: 1.0)
    }
}

public  func getAppBuild() -> String {
    return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
}
