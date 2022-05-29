//
//  Coordinator.swift
//  RetailLegacy
//
//  Created by Francisco del Real Escudero on 9/4/21.
//

import CoreFoundationLib
import CoreDomain

public protocol OfferCoordinatorLauncher {
    func executeOffer(_ offer: OfferRepresentable)
}
