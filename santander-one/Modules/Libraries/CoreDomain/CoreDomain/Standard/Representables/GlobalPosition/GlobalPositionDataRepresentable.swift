//
//  GlobalPositionRepresentable.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/14/21.
//

public protocol GlobalPositionDataRepresentable {
    var userId: String? { get }
    var loanRepresentables: [LoanRepresentable] { get }
    var accountRepresentables: [AccountRepresentable] { get }
    var stockAccountRepresentables: [StockAccountRepresentable] { get }
    var cardRepresentables: [CardRepresentable] { get }
    var depositRepresentables: [DepositRepresentable] { get }
    var fundRepresentables: [FundRepresentable] { get }
    var managedPortfoliosRepresentables: [PortfolioRepresentable] { get }
    var notManagedPortfoliosRepresentables: [PortfolioRepresentable] { get }
    var managedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] { get }
    var notManagedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] { get }
    var pensionRepresentables: [PensionRepresentable] { get }
    var savingsInsuranceRepresentables: [InsuranceRepresentable] { get }
    var protectionInsuranceRepresentables: [InsuranceRepresentable] { get }
    var savingProductRepresentables: [SavingProductRepresentable] { get }
    var userDataRepresentable: UserDataRepresentable? { get }
    var isPb: Bool? { get }
    var clientNameWithoutSurname: String? { get }
    var clientName: String? { get }
    var clientFirstSurnameRepresentable: String? { get }
    var clientSecondSurnameRepresentable: String? { get }
}

public protocol GlobalPositionAndUserPrefMergedRepresentable {
    var loans: [GlobalPositionMergedProduct<LoanRepresentable>] { get }
    var accounts: [GlobalPositionMergedProduct<AccountRepresentable>] { get }
    var stockAccounts: [GlobalPositionMergedProduct<StockAccountRepresentable>] { get }
    var cards: [GlobalPositionMergedProduct<CardRepresentable>] { get }
    var deposits: [GlobalPositionMergedProduct<DepositRepresentable>] { get }
    var funds: [GlobalPositionMergedProduct<FundRepresentable>] { get }
    var pensions: [GlobalPositionMergedProduct<PensionRepresentable>] { get }
    var savingsInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] { get }
    var protectionInsurances: [GlobalPositionMergedProduct<InsuranceRepresentable>] { get }
    var savingsProducts: [GlobalPositionMergedProduct<SavingProductRepresentable>] { get }
}

public struct GlobalPositionMergedProduct<Product> {
    public let product: Product
    public let isVisible: Bool
    
    public init(product: Product, isVisible: Bool) {
        self.product = product
        self.isVisible = isVisible
    }
}
