//
//  CashTypeViewModelBuilder.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 11/10/20.
//

import Foundation

final class CashTypeViewModelBuilder {
    var billViewModels = [AtmElementViewModel]()
    
    func add10Bill(_ has10Bills: Bool?) -> Self {
        guard let has10Bills = has10Bills else { return self }
        self.billViewModels.append(AtmElementViewModel(localizedKey: "atm_label_amount10", isAvailable: has10Bills))
        return self
    }
    
    func add20Bill(_ has20Bills: Bool?) -> Self {
        guard let has20Bills = has20Bills else { return self }
        self.billViewModels.append(AtmElementViewModel(localizedKey: "atm_label_amount20", isAvailable: has20Bills))
        return self
    }
    
    func add50Bill(_ has50Bills: Bool?) -> Self {
        guard let has50Bills = has50Bills else { return self }
        self.billViewModels.append(AtmElementViewModel(localizedKey: "atm_label_amount50", isAvailable: has50Bills))
        return self
    }
    
    func build() -> [AtmElementViewModel] {
        return billViewModels
    }
}
