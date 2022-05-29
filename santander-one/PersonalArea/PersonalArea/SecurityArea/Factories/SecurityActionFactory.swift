//
//  SecurityActionFactory.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import Foundation
import CoreFoundationLib

final class SecurityActionFactory {
    func getActions(userPref: UserPrefWrapper?,
                    offer: OfferEntity?,
                    deviceState: ValidatedDeviceStateEntity,
                    completion: @escaping ([SecurityActionViewModelProtocol]) -> Void) {
        guard let userPreference = userPref else {
            completion([])
            return
        }
        let views = SecurityActionBuilder(userPreference)
            .addPhone()
            .addMail()
            .addBiometrySystem()
            .addGeolocation()
            .addVideo(offer)
            .addSecureDevice(deviceState, offer, true)
            .addUser()
            .addPasswordSignatureKey()
            .addSignatureKey()
            .build()
        completion(views)
    }
    
    static func getAlertConfiguration(_ offer: OfferEntity?) -> SecurityViewModel? {
        guard offer != nil else { return nil }
         return SecurityViewModel(
             title: "security_button_notification",
             subtitle: "security_text_superInformed",
             icon: "icnRing"
         )
     }
}

extension SecurityActionFactory: SecurityAreaActionProtocol { }
