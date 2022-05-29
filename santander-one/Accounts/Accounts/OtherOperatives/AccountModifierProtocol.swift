//
//  AccountModifierProtocol.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 21/5/21.
//

import Foundation
import CoreFoundationLib

public protocol AccountModifierProtocol {
    var accountsOtherOperatives: [PullOfferLocation] { get }
    var contractAccountLocation: String { get }
    var filteringBySituationType: Bool { get }
}
