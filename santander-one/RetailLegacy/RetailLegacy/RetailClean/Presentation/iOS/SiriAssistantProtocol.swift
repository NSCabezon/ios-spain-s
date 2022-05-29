//
//  SiriAssistantProtocol.swift
//  RetailLegacy
//
//  Created by Juan Carlos López Robles on 12/30/20.
//

import Intents
import Foundation

public protocol SiriAssistantProtocol {
    func donate(completion: @escaping (INIntent?) -> Void)
    func getSiriIntentResponseCode(userActivity: NSUserActivity) -> SiriIntentResponseCode?
}

public enum SiriIntentResponseCode {
    case unspecified
    case ready
    case continueInApp
    case inProgress
    case success
    case failure
    case failureRequiringAppLaunch
    case callOK(String)
    case noToken
    case callOkNoManager
}
