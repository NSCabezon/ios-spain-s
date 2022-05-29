//
//  Animations.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/29/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation
import UIKit

public class Animations {
    public static func requireUserAtencion(on onView: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: onView.center.x - 10, y: onView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: onView.center.x + 10, y: onView.center.y))
        onView.layer.add(animation, forKey: "position")
    }
}
