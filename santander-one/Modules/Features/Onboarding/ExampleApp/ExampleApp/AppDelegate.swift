//
//  AppDelegate.swift
//  ExampleApp
//
//  Created by Jose Ignacio de Juan Díaz on 22/11/21.
//

import UIKit
import UI

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIStyle.setup()
        window = UIWindow()
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()        
        return true
    }
    
}
