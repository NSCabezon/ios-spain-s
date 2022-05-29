//
//  BankConfigurationDetailConfiguration.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 15/7/21.
//

import Foundation

final class BankConfigurationDetailConfiguration {
    let selectedBank: OtherBankConfigViewModel
    
    init(selectedBank: OtherBankConfigViewModel) {
        self.selectedBank = selectedBank
    }
}
