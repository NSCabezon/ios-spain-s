//
//  AccountsCarouselViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 24/08/2020.
//

import Foundation
import CoreFoundationLib

struct AccountsCarouselViewModel {
    private let financeableInfoCarousel: FinanceableInfoViewModel.AccountsCarousel
    
    init(_ info: FinanceableInfoViewModel.AccountsCarousel) {
        self.financeableInfoCarousel = info
    }
    
    var accounts: [AccountFinanceableViewModel] {
        let viewModels = self.financeableInfoCarousel.accounts.map(AccountFinanceableViewModel.init)
        _ = viewModels.sorted(by: {$0.name < $1.name})
        return viewModels
    }
    
    var isSelectorHidden: Bool {
        guard !self.accounts.isEmpty, accounts.count > 1 else {
            return true
        }
        return false
    }
    
    var selectedAccount: AccountFinanceableViewModel? {
        guard !self.accounts.isEmpty else { return nil }
        return self.accounts[0]
    }
}
