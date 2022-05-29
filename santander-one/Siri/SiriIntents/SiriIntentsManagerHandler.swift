//
//  SiriIntentsManagerHandler.swift
//  RetailLegacy_Example
//
//  Created by Juan Carlos López Robles on 12/30/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import Intents
import Foundation
import RetailLegacy

final class SiriIntentsManagerHandler: SiriAssistantProtocol {
    func donate(completion: @escaping (INIntent?) -> Void) {
        guard #available(iOS 12.0, *) else {
            completion(nil)
            return
        }
        completion(CallToManagerIntent())
    }
    
    func getSiriIntentResponseCode(userActivity: NSUserActivity) -> SiriIntentResponseCode? {
        guard #available(iOS 12.0, *) else {
            return nil
        }
        guard let callToManagerIntentResponse = userActivity.interaction?.intentResponse as? CallToManagerIntentResponse else {
            return nil
        }
        switch callToManagerIntentResponse.code {
        case .unspecified:
            return .unspecified
        case .ready:
            return .ready
        case .continueInApp:
            return .continueInApp
        case .inProgress:
            return .inProgress
        case .success:
            return .success
        case .failure:
            return .failure
        case .failureRequiringAppLaunch:
            return .failureRequiringAppLaunch
        case .callOK:
            guard let phone = callToManagerIntentResponse.availablePhone else {
                return nil
            }
            return .callOK(phone)
        case .noToken:
            return .noToken
        case .callOkNoManager:
            return .callOkNoManager
        }
    }
}
