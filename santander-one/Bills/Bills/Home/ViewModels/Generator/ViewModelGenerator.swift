//
//  ViewModelGenerator.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 2/21/20.
//

import Foundation
import CoreFoundationLib
import CoreDomain

final class ViewModelGenerator {
    let dependenciesResolver: DependenciesResolver
    let localizedDate: LocalizedDate
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.localizedDate = LocalizedDate(dependenciesResolver: dependenciesResolver)
    }
    
    func lastBillsViewModels(for accountBills: [AccountEntity: [LastBillEntity]]) -> [LastBillViewModel] {
        let viewModels = accountBills.flatMap { element in
            self.lastBillViewModel(for: element.key, bills: element.value)
        }
        return viewModels
    }
    
    func futureBillsViewModels(for accountBills: [AccountEntity: [AccountFutureBillRepresentable]]) -> [FutureBillViewModel] {
        let viewModels = accountBills.flatMap { element in
            self.futureBillViewModel(for: element.key, bills: element.value)
        }.sorted(by: {$0.date < $1.date})
        return viewModels
    }
}

private extension ViewModelGenerator {
    func lastBillViewModel(for account: AccountEntity, bills: [LastBillEntity]) -> [LastBillViewModel] {
        return bills.map { LastBillViewModel($0, account: account, localizedDate: localizedDate) }
    }
    
    func futureBillViewModel(for account: AccountEntity, bills: [AccountFutureBillRepresentable]) -> [FutureBillViewModel] {
        return bills.map { FutureBillViewModel($0, account: account, localizedDate: localizedDate) }
    }
}
