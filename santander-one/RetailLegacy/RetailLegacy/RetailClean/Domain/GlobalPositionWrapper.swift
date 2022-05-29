import SANLegacyLibrary
import CoreFoundationLib
import Foundation
import CoreDomain

class GlobalPositionWrapper {
    
    static func createFromDTO(
        isPb: Bool,
        isMixedUser: Bool,
        globalPositionConfig: GlobalPositionConfig,
        dto: GlobalPositionDTO,
        cardsData: [String: CardDataDTO]?,
        prepaidCards: [String: PrepaidCardDataDTO]?,
        cardBalances: [String: CardBalanceDTO]?,
        temporallyOffCards: [String: InactiveCardDTO]?,
        inactiveCards: [String: InactiveCardDTO]?,
        notManagedRVStockAccounts: [StockAccountDTO]?,
        managedRVStockAccounts: [StockAccountDTO]?,
        notManagedPortfolios: [PortfolioDTO]?,
        managedPortfolios: [PortfolioDTO]?,
        userSegmentDTO: UserSegmentDTO?,
        accountDescriptors: [AccountDescriptorDTO]?,
        isInsuranceAmountEnabled: Bool) -> GlobalPositionWrapper {
        return GlobalPositionWrapper(
            dto,
            isPb,
            isMixedUser,
            globalPositionConfig,
            AccountList.createFrom(dto.accounts, accountDescriptors),
            CardList.createFrom(dtos: dto.cards, cardsData: cardsData, prepaidCardsData: prepaidCards, cardBalances: cardBalances, temporallyOffCards: temporallyOffCards, inactiveCards: inactiveCards),
            DepositList.create(dto.deposits),
            FundList.create(dto.funds),
            PensionList.create(dto.pensions),
            LoanList.create(dto.loans),
            StockAccountList.create(dto.stockAccounts, stockAccountType: StockAccountType.CCV),
            InsuranceSavingList.create(dto.savingsInsurances),
            InsuranceProtectionList.create(dto.protectionInsurances),
            StockAccountList.create(notManagedRVStockAccounts, stockAccountType: StockAccountType.RVNotManaged),
            StockAccountList.create(managedRVStockAccounts, stockAccountType: StockAccountType.RVManaged),
            PortfolioList.create(notManagedPortfolios),
            PortfolioList.create(managedPortfolios),
            UserSegment.createFromDTO(userSegmentDTO),
            isInsuranceAmountEnabled)
    }

    var dto: GlobalPositionDTO
    var isPb: Bool
    var isMixedUser: Bool
    var globalPositionConfig: GlobalPositionConfig
    var accounts: AccountList
    var cards: CardList
    var stockAccounts: StockAccountList
    var deposits: DepositList
    var loans: LoanList
    var notManagedRVStockAccounts: StockAccountList
    var managedRVStockAccounts: StockAccountList
    var notManagedPortfolios: PortfolioList
    var managedPortfolios: PortfolioList
    var pensions: PensionList
    var funds: FundList
    var insuranceSavings: InsuranceSavingList
    var insuranceProtection: InsuranceProtectionList
    var userSegment: UserSegment?
    let isInsuranceBalanceEnabled: Bool
    
    var userId: String {
        let userDo = UserDO(dto: dto.userDataDTO)
        return userDo.userId ?? ""
    }
    
    var userCodeType: String {
        let userDo = UserDO(dto: dto.userDataDTO)
        return userDo.userCodeType ?? ""
    }
    
    var getAccountsVisiblesWithoutPiggy: [Account] {
        return accounts.getVisibles().filter { $0.isPiggyBankAccount == false }
    }
        
    var getAccountsNotVisiblesWithoutPiggy: [Account] {
        return accounts.getNotVisibles().filter { $0.isPiggyBankAccount == false }
    }
    
    var getAllAccountsWithoutPiggy: [Account] {
        return accounts.get().filter { $0.isPiggyBankAccount == false }
    }
    
    private init(_ dto: GlobalPositionDTO,
                 _ isPb: Bool,
                 _ isMixedUser: Bool,
                 _ globalPositionConfig: GlobalPositionConfig,
                 _ accountList: AccountList,
                 _ cardList: CardList,
                 _ depositList: DepositList,
                 _ fundList: FundList,
                 _ pensionList: PensionList,
                 _ LoanListBO: LoanList,
                 _ stockAccountList: StockAccountList,
                 _ insuranceSavingsList: InsuranceSavingList,
                 _ insuranceProtectionList: InsuranceProtectionList,
                 _ notManagedRVStockAccounts: StockAccountList,
                 _ managedRVStockAccounts: StockAccountList,
                 _ notManagedPortfoliosList: PortfolioList,
                 _ managedPortfoliosList: PortfolioList,
                 _ userSegment: UserSegment?,
                 _ isInsuranceAmountEnabled: Bool) {

        self.dto = dto
        self.isPb = isPb
        self.isMixedUser = isMixedUser
        self.globalPositionConfig = globalPositionConfig
        self.accounts = accountList
        self.cards = cardList
        self.deposits = depositList
        self.funds = fundList
        self.pensions = pensionList
        self.loans = LoanListBO
        self.stockAccounts = stockAccountList
        self.insuranceSavings = insuranceSavingsList
        self.insuranceProtection = insuranceProtectionList
        self.notManagedRVStockAccounts = notManagedRVStockAccounts
        self.managedRVStockAccounts = managedRVStockAccounts
        self.notManagedPortfolios = notManagedPortfoliosList
        self.managedPortfolios = managedPortfoliosList
        self.userSegment = userSegment
        self.isInsuranceBalanceEnabled = isInsuranceAmountEnabled
    }
    
    func getTotalFinancing() throws -> Amount {
        var total: Decimal = 0
        
        if let enableCounterValue = globalPositionConfig.isEnabledCounterValue(), enableCounterValue == true {
            total += accounts.getTotalCounterValueFromCreditsAccounts(filter: nil)
            total += loans.getTotalCountervalue(filter: nil)
            total += cards.getTotalCounterCreditBalance(currencyType: CoreCurrencyDefault.default, visibles: true)
        } else {
            total += try accounts.getTotalAmountFromCreditsAccounts(CoreCurrencyDefault.default)
            total += try loans.getTotal(CoreCurrencyDefault.default)
            total += try cards.getTotalCreditBalance(currencyType: CoreCurrencyDefault.default, visibles: true)
        }
        return Amount.createFromDTO(AmountDTO(value: total, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
    }
    
    func getTotalMoney() throws -> Amount {
        var total: Decimal = 0
        
        if let enableCounterValue = globalPositionConfig.isEnabledCounterValue(), enableCounterValue == true {
            total += accounts.getTotalCounterValueWithoutCreditsAccounts(filter: nil)
            total += deposits.getTotalCounterValue(filter: nil)
            total += funds.getTotalCounterValue(filter: nil)
            total += stockAccounts.getTotalCounterValue(filter: nil)
            total += pensions.getTotalCounterValue(filter: nil)
            if isInsuranceBalanceEnabled {
                total += insuranceSavings.getTotalCounterValue(filter: nil)
            }
        } else {
            total += try accounts.getTotalAmountWithoutCreditAccounts(CoreCurrencyDefault.default)
            total += try deposits.getTotal(CoreCurrencyDefault.default)
            total += try funds.getTotal(CoreCurrencyDefault.default)
            total += try stockAccounts.getTotal(CoreCurrencyDefault.default)
            total += try pensions.getTotal(CoreCurrencyDefault.default)
            if isInsuranceBalanceEnabled {
                total += try insuranceSavings.getTotal(CoreCurrencyDefault.default)
            }
        }
        
        // not affected by counterValue
        total += try managedPortfolios.getTotal(CoreCurrencyDefault.default)
        total += try notManagedPortfolios.getTotal(CoreCurrencyDefault.default)
        total += cards.getTotalPrepaidBalance(visibles: true)
        
        return Amount.createFromDTO(AmountDTO(value: total, currency: CurrencyDTO.create(CoreCurrencyDefault.default)))
    }
}

extension GlobalPositionWrapper: GlobalPositionNameProtocol  {
    var globalPositionDataRepresentable: GlobalPositionDataRepresentable {
        dto
    }
}
