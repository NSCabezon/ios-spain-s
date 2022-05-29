//
//  AppEventsNotifierSubscriptor.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/10/20.
//

import Foundation

public protocol AppEventWillEnterForegroundSuscriptor: Subscriptor {
    func applicationWillEnterForeground()
}

public protocol AppEventDidBecomeActiveSuscriptor: Subscriptor {
    func applicationDidBecomeActive()
}

public protocol AppEventWillResignActiveSuscriptor: Subscriptor {
    func applicationWillResignActive()
}

public protocol AppEventsNotifierProtocol {
    func add(willEnterForegroundSubscriptor: AppEventWillEnterForegroundSuscriptor)
    func add(didBecomeActiveSubscriptor: AppEventDidBecomeActiveSuscriptor)
    func add(willResignActiveSubscriptor: AppEventWillResignActiveSuscriptor)
    func remove(willEnterForegroundSubscriptor: AppEventWillEnterForegroundSuscriptor)
    func remove(didBecomeActiveSubscriptor: AppEventDidBecomeActiveSuscriptor)
    func remove(willResignActiveSubscriptor: AppEventWillResignActiveSuscriptor)
}
