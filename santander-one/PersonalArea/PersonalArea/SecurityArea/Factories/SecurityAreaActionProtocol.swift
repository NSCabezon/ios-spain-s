//
//  SecurityAreaActionProtocol.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 26/4/21.
//

import Foundation
import CoreFoundationLib

public protocol SecurityAreaActionProtocol {
    func getActions(userPref: UserPrefWrapper?,
                    offer: OfferEntity?,
                    deviceState: ValidatedDeviceStateEntity,
                    completion: @escaping ([SecurityActionViewModelProtocol]) -> Void)
}
