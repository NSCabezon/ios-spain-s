import Foundation
import CoreDomain

public struct GlobalPositionDTO: Codable {
    public var stockAccounts: [StockAccountDTO]?
    public var accounts: [AccountDTO]?
    public var cards: [CardDTO]?
    public var deposits: [DepositDTO]?
    public var funds: [FundDTO]?
    public var loans: [LoanDTO]?
    public var pensions: [PensionDTO]?
    public var savingsInsurances: [InsuranceDTO]?
    public var protectionInsurances: [InsuranceDTO]?
    public var savingProducts: [SavingProductDTO]?

    public var sepaMigratedInd: Bool?
    public var banestoMigratedInd: Bool?
    public var clientName: String?
    public var userDataDTO: UserDataDTO?

    public var clientNameWithoutSurname: String?
    public var clientFirstSurname: SurNameDTO?
    public var clientSecondSurname: SurNameDTO?
    public var clientBirthDate: Date?
    public var isPb: Bool?

    public var notManagedPortfolios: [PortfolioDTO]?
    public var managedPortfolios: [PortfolioDTO]?
    public var notManagedRVStockAccounts: [StockAccountDTO]?
    public var managedRVStockAccounts: [StockAccountDTO]?
    
    public init () {}
}

extension GlobalPositionDTO: GlobalPositionDataRepresentable {
    public var userId: String? {
        guard let userData = userDataRepresentable,
              let userType = userData.clientPersonType,
              let userCode = userData.clientPersonCode else {
                  return nil
              }
        return userType + userCode
    }
    public var loanRepresentables: [LoanRepresentable] {
        return loans ?? []
    }
    public var accountRepresentables: [AccountRepresentable] {
        return accounts ?? []
    }
    public var stockAccountRepresentables: [StockAccountRepresentable] {
        return stockAccounts ?? []
    }
    public var cardRepresentables: [CardRepresentable] {
        return cards ?? []
    }
    public var depositRepresentables: [DepositRepresentable] {
        return deposits ?? []
    }
    public var fundRepresentables: [FundRepresentable] {
        return funds ?? []
    }
    public var managedPortfoliosRepresentables: [PortfolioRepresentable] {
        return managedPortfolios ?? []
    }
    public var notManagedPortfoliosRepresentables: [PortfolioRepresentable] {
        return notManagedPortfolios ?? []
    }
    public var managedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] {
        return managedRVStockAccounts ?? []
    }
    public var notManagedPortfolioVariableIncomeRepresentables: [StockAccountRepresentable] {
        return notManagedRVStockAccounts ?? []
    }
    public var pensionRepresentables: [PensionRepresentable] {
        return pensions ?? []
    }
    public var savingsInsuranceRepresentables: [InsuranceRepresentable] {
        return savingsInsurances ?? []
    }
    public var protectionInsuranceRepresentables: [InsuranceRepresentable] {
        return protectionInsurances ?? []
    }
    public var savingProductRepresentables: [SavingProductRepresentable] {
        return savingProducts ?? []
    }
    public var userDataRepresentable: UserDataRepresentable? {
        return userDataDTO
    }
    public var clientFirstSurnameRepresentable: String? {
        return clientFirstSurname?.surname
    }
    public var clientSecondSurnameRepresentable: String? {
        return clientSecondSurname?.surname
    }
}
