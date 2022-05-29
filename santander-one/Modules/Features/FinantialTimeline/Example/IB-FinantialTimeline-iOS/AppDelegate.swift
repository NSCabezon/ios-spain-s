//
//  AppDelegate.swift
//  IB-FinantialTimeline-iOS
//
//  Created by esepakuto on 06/24/2019.
//  Copyright (c) 2019 esepakuto. All rights reserved.
//

import UIKit
import netfox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool{
        setNetFox()
        return true
    }
}


// MARK: - Frameworks
extension AppDelegate {
    func setNetFox() {
        NFX.sharedInstance().start()
        NFX.sharedInstance().ignoreURL("https://api.crashlytics.com")
        NFX.sharedInstance().ignoreURL("https://settings.crashlytics.com")
        NFX.sharedInstance().ignoreURL("https://play.googleapis.com")
    }
}
