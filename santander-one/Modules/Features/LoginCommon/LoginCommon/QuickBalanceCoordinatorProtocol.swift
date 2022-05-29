//
//  LoginCoordinatorDelegate.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 12/3/20.
//

import Foundation
import CoreFoundationLib

public protocol QuickBalanceCoordinatorProtocol {
    func didSelectDismiss()
    func didSelectOffer(_ offer: OfferEntity, location: PullOfferLocation)
    func didSelectDeeplink(_ identifier: String)
}
