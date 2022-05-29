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
    
    @available(iOS 12.0, *)
    private func callToManagerIntentResponseToSiriIntentResponseCodeDictionary (responseCode: CallToManagerIntentResponse) -> SiriIntentResponseCode? {
        var callToManagerToSiriIntentResponseCode: [CallToManagerIntentResponseCode: SiriIntentResponseCode] = [
            .unspecified: .unspecified,
            .ready: .ready,
            .continueInApp: .continueInApp,
            .inProgress: .inProgress,
            .success: .success,
            .failure: .failure,
            .failureRequiringAppLaunch: .failureRequiringAppLaunch,
            .noToken: .noToken,
            .callOkNoManager: .callOkNoManager
        ]
        callToManagerToSiriIntentResponseCode[.callOK] = {
            guard let phone = responseCode.availablePhone else { return nil }
            return .callOK(phone)
        }()
        return callToManagerToSiriIntentResponseCode[responseCode.code]
    }
    
    func getSiriIntentResponseCode(userActivity: NSUserActivity) -> SiriIntentResponseCode? {
        guard #available(iOS 12.0, *) else {
            return nil
        }
        guard let callToManagerIntentResponse = userActivity.interaction?.intentResponse as? CallToManagerIntentResponse else {
            return nil
        }
        return callToManagerIntentResponseToSiriIntentResponseCodeDictionary(responseCode: callToManagerIntentResponse)
    }
}
