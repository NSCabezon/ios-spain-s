//
//  TrackManagerMock.swift
//  Example
//
//  Created by Rubén Márquez Fernández on 10/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import CoreFoundationLib

class TrackerManagerMock: TrackerManager {
    
    func trackScreen(screenId: String, extraParameters: [String: String]) {
        print("TrackScreen screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        print("TrackEvent (eventId: \(eventId), screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEmma(token: String) {
        print("METRICS token Emma: \(token)")
    }
}
