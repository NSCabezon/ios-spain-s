//
//  TrackerManagerMock.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 2/24/22.
//

import Foundation
import CoreFoundationLib

public final class TrackerManagerMock: TrackerManager {
    public var screenId: String?
    public var eventId: String?
    public var token: String?
    public var extraParameters: [String: String]?
    
    public init() {
    }
    
    public func trackScreen(screenId: String, extraParameters: [String: String]) {
        self.screenId = screenId
        self.extraParameters = extraParameters
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        self.screenId = screenId
        self.eventId = eventId
        self.extraParameters = extraParameters
    }
    
    public func trackEmma(token: String) {
        self.token = token
    }
}
