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

//TODO: uncomment the lines below when siri clases already added
final class SiriIntentsManagerHandler: SiriAssistantProtocol {
    
    func donate(completion: @escaping (INIntent?) -> Void) {
        ///completion(CallToManagerIntent())
    }
    
    func getSiriIntentResponseCode(userActivity: NSUserActivity) -> SiriIntentResponseCode? {
      /**  guard #available(iOS 12.0, *), let intentResponse = userActivity.interaction?.intentResponse as? CallToManagerIntentResponse
        else {
            return .unspecified
        }

        switch intentResponse.code {
        case .callOK:
            return .callOK(intentResponse.availablePhone)
        case .callOkNoManager:
            return .callOkNoManager
        case .noToken:
            return .noToken
        default:
            return .unspecified
        }*/
        return .unspecified
    }
}
