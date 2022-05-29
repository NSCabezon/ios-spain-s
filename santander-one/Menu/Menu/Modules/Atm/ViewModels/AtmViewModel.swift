//
//  AtmViewModel.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/28/20.
//

import Foundation
import CoreFoundationLib

final class AtmViewModel {
    let atmEntity: AtmEntity
    
    init(_ entity: AtmEntity) {
        self.atmEntity = entity
    }
    
    var address: String {
        return String(format: "%@, %@, %@", self.atmEntity.location.address,
                      self.atmEntity.location.zipCode,
                      atmEntity.location.city)
    }
    
    var street: String {
        return atmEntity.address
    }
    
    var distance: LocalizedStylableText {
        return self.getDistanceDescription(from: self.atmEntity.distanceInKM)
    }
    
    var isOperative: Bool {
        switch self.atmEntity.poiStatus {
        case .active:
            return true
        default:
            return false
        }
    }
    
    var isAtmDetailAvailable: Bool {
        return !(services.isEmpty && cashTypes.isEmpty)
    }
    
    var hasDeposit: Bool? {
        return self.atmEntity.hasDeposit
    }
    
    var hasContactLess: Bool? {
        return self.atmEntity.hasContactLess
    }
    
    var hasBarsCode: Bool? {
        return self.atmEntity.hasBarsCode
    }
    
    var cashTypes: [AtmElementViewModel] {
        guard self.atmEntity.containEnrichedInformation else { return [] }
        return CashTypeViewModelBuilder()
            .add10Bill(self.atmEntity.has10Bills)
            .add20Bill(self.atmEntity.has20Bills)
            .add50Bill(self.atmEntity.has50Bills)
            .build()
    }
    
    var services: [AtmElementViewModel] {
        guard self.atmEntity.containEnrichedInformation else { return [] }
        return ServiceViewModelBuilder()
            .addDeposit(self.atmEntity.hasDeposit)
            .addContactLess(self.atmEntity.hasContactLess)
            .addBarsCode(self.atmEntity.hasBarsCode)
            .build()
    }
}

private extension AtmViewModel {
    func getDistanceDescription(from distanceInKm: Double) -> LocalizedStylableText {
        if distanceInKm < 1 {
            return self.convertToMeters(distanceInKm)
        } else {
            return self.convertToRoundKm(distanceInKm)
        }
    }
    
    func convertToMeters(_ distanceInKm: Double) -> LocalizedStylableText {
        let meters = distanceInKm * 1000
        let distanceString = String(format: "%.0f", meters)
        return localized("atm_label_distanceMeters", [StringPlaceholder(.value, distanceString)])
    }
    
    func convertToRoundKm(_ distanceInKm: Double) -> LocalizedStylableText {
        let hasDecimals = floor(distanceInKm) != distanceInKm
        if hasDecimals {
            let distanceString = String(format: "%.2f", distanceInKm)
            return localized("atm_label_distanceKilometres", [StringPlaceholder(.value, distanceString)])
        } else {
            let distanceString = String(format: "%.0f", distanceInKm)
            return localized("atm_label_distanceKilometres", [StringPlaceholder(.value, distanceString)])
        }
    }
}
