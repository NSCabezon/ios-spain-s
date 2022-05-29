//
//  MockGlobalPositionAndUserPrefMergedRepresentable.swift
//  UnitTestCommons
//
//  Created by Mario Rosales Maillo on 28/2/22.
//

import Foundation
import CoreDomain

public struct MockGlobalPositionAndUserPrefMergedRepresentable : GlobalPositionAndUserPrefMergedRepresentable {
    
    public init(accounts: [AccountRepresentable]) {
        self.accounts = accounts.map({ account in
            return GlobalPositionMergedProduct<AccountRepresentable>(product: account, isVisible: true)
        })
    }
    
    public var loans: [GlobalPositionMergedProduct<LoanRepresentable>] = []
    public var accounts: [GlobalPositionMergedProduct<AccountRepresentable>]
    public var stockAccounts: [GlobalPositionMergedProduct<StockAccountRepresentable>] = []
    public var cards: [GlobalPositionMergedProduct<CardRepresentable>] = []
    public var deposits: [GlobalPositionMergedProduct<DepositRepresentable>] = []
    public var funds: [GlobalPositionMergedProduct<FundRepresentable>] = []
    public var pensions: [GlobalPositionMergedProduct<PensionRepresentable>] = []
    public var savingsInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] = []
    public var protectionInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] = []
    public var savingsProducts: [GlobalPositionMergedProduct<SavingProductRepresentable>] = []
}
