//
//  ServiceViewModelBuilder.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 11/10/20.
//

import Foundation

final class ServiceViewModelBuilder {
    var serviceViewModels = [AtmElementViewModel]()
    
    func addDeposit(_ hasDeposit: Bool?) -> Self {
        guard let hasDeposit = hasDeposit else { return self }
        self.serviceViewModels.append(  AtmElementViewModel(localizedKey: "atm_label_checkDepositCash", isAvailable: hasDeposit))
        return self
    }
    
    func addContactLess(_ hasContactLess: Bool?) -> Self {
        guard let hasContactLess = hasContactLess else { return self }
        self.serviceViewModels.append(AtmElementViewModel(localizedKey: "atm_label_checkContactless", isAvailable: hasContactLess))
        return self
    }
    
    func addBarsCode(_ hasBarsCode: Bool?) -> Self {
        guard let hasBarsCode = hasBarsCode else { return self }
        self.serviceViewModels.append(AtmElementViewModel(localizedKey: "atm_label_barcodeReader", isAvailable: hasBarsCode))
        return self
    }
    
    func build() -> [AtmElementViewModel] {
        return serviceViewModels
    }
}
