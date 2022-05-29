//
//  AppHelper.swift
//  IB-FinantialTimeline-iOS
//
//  Created by Hernán Villamil on 04/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

class AppHelper {
    // Get Current View Controller
    class func getCurrentViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        guard let viewController = viewController else { return nil }
        
        if let viewController = viewController as? UINavigationController {
            if let viewController = viewController.visibleViewController {
                return getCurrentViewController(viewController)
            } else {
                return getCurrentViewController(viewController.topViewController)
            }
        } else if let viewController = viewController as? UITabBarController {
            if let viewControllers = viewController.viewControllers, viewControllers.count > 5, viewController.selectedIndex >= 4 {
                return getCurrentViewController(viewController.moreNavigationController)
            } else {
                return getCurrentViewController(viewController.selectedViewController)
            }
        } else if let viewController = viewController.presentedViewController {
            return viewController
        } else if viewController.children.count > 0 {
            return viewController.children[0]
        } else {
            return viewController
        }
    }
}
