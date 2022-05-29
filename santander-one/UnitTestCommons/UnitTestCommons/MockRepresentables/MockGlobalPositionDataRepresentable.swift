//
//  MockGlobalPositionDataRepresentable.swift
//  UnitTestCommons
//
//  Created by Mario Rosales Maillo on 28/2/22.
//

import Foundation
import CoreDomain

public struct MockGlobalPositionDataRepresentable : GlobalPositionDataRepresentable {
    
    public init(accounts: [AccountRepresentable]) {
        self.accountRepresentables = accounts
    }
    
    public var userId: String?
    public var loanRepresentables: [LoanRepresentable] = []
    public var accountRepresentables: [AccountRepresentable]
    public var stockAccountRepresentables: [StockAccountRepresentable] = []
    public var cardRepresentables: [CardRepresentable] = []
    public var depositRepresentables: [DepositRepresentable] = []
    public var fundRepresentables: [FundRepresentable] = []
    public var managedPortfoliosRepresentables: [PortfolioRepresentable] = []
    public var notManagedPortfoliosRepresentables: [PortfolioRepresentable] = []
    public var managedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] = []
    public var notManagedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] = []
    public var pensionRepresentables: [PensionRepresentable] = []
    public var savingsInsuranceRepresentables: [InsuranceRepresentable] = []
    public var protectionInsuranceRepresentables: [InsuranceRepresentable] = []
    public var savingProductRepresentables: [SavingProductRepresentable] = []
    public var userDataRepresentable: UserDataRepresentable?
    public var isPb: Bool?
    public var clientNameWithoutSurname: String?
    public var clientName: String?
    public var clientFirstSurnameRepresentable: String?
    public var clientSecondSurnameRepresentable: String?
}
