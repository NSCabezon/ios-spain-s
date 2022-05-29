import SANLegacyLibrary

public protocol GlobalPositionRepresentable {
    var userId: String? { get }
    var userCodeType: String? { get }
    var dto: GlobalPositionDTO? { get }
    var accounts: [AccountEntity] { get set }
    var cards: [CardEntity] { get set }
    var stockAccounts: [StockAccountEntity] { get set }
    var loans: [LoanEntity] { get set }
    var deposits: [DepositEntity] { get set }
    var pensions: [PensionEntity] { get set }
    var funds: [FundEntity] { get set }
    var notManagedPortfolios: [PortfolioEntity] { get set }
    var managedPortfolios: [PortfolioEntity] { get set }
    var notManagedPortfolioVariableIncome: [StockAccountEntity] { get set }
    var managedPortfolioVariableIncome: [StockAccountEntity] { get set }
    var insuranceSavings: [InsuranceSavingEntity] { get set }
    var protectionInsurances: [InsuranceProtectionEntity] { get set }
    var savingProducts: [SavingProductEntity] { get set }
    var isPb: Bool? { get }
    var clientNameWithoutSurname: String? { get }
    var clientSurname: String? { get }
    var clientBothSurnames: String? { get }
    var clientSecondSurname: String? { get }
    var availableName: String? { get }
    var fullName: String { get }
    var clientBirthDate: Date? { get }
}

public class GlobalPositionEntity: GlobalPositionRepresentable {
    public var dto: GlobalPositionDTO?
    public var isPb: Bool?
    public var accounts: [AccountEntity]
    public var cards: [CardEntity]
    public var stockAccounts: [StockAccountEntity]
    public var deposits: [DepositEntity]
    public var loans: [LoanEntity]
    public var notManagedPortfolios: [PortfolioEntity]
    public var managedPortfolios: [PortfolioEntity]
    public var notManagedPortfolioVariableIncome: [StockAccountEntity]
    public var managedPortfolioVariableIncome: [StockAccountEntity]
    public var pensions: [PensionEntity]
    public var funds: [FundEntity]
    public var insuranceSavings: [InsuranceSavingEntity]
    public var protectionInsurances: [InsuranceProtectionEntity]
    public var savingProducts: [SavingProductEntity]
    
    public var userId: String? {
        guard let userDataDTO = dto?.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userType + userCode
    }
    
    public var userCodeType: String? {
        guard let userDataDTO = dto?.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userCode + userType
    }
    
    public var clientNameWithoutSurname: String? {
        return dto?.clientNameWithoutSurname
    }
    
    public var clientSurname: String? {
        return dto?.clientFirstSurname?.surname
    }
    
    public var clientBothSurnames: String? {
        guard let first = dto?.clientFirstSurname?.surname, let second = dto?.clientSecondSurname?.surname else { return nil }
        return "\(first) \(second)"
    }
    
    public var clientSecondSurname: String? {
        dto?.clientSecondSurname?.surname
    }
    
    public var availableName: String? {
        guard let name = dto?.clientNameWithoutSurname, let lastName = dto?.clientFirstSurname?.surname, !name.isEmpty, !lastName.isEmpty else { return dto?.clientName ?? "" }
        return "\(name) \(lastName)"
    }
    
    public var fullName: String {
        guard let name: String = dto?.clientNameWithoutSurname, let firstSurnameName: String = dto?.clientFirstSurname?.surname, let secondSurnameName: String = dto?.clientSecondSurname?.surname, !name.isEmpty, !firstSurnameName.isEmpty else {
            return dto?.clientName ?? ""
        }
        return "\(name) \(firstSurnameName) \(secondSurnameName)"
    }
    
    public var clientBirthDate: Date? {
        return dto?.clientBirthDate
    }
    
    public init(
        isPb: Bool?,
        dto: GlobalPositionDTO?,
        cardsData: [String: CardDataDTO]?,
        prepaidCards: [String: PrepaidCardDataDTO]?,
        cardBalances: [String: CardBalanceDTO]?,
        temporallyOffCards: [String: InactiveCardDTO]?,
        inactiveCards: [String: InactiveCardDTO]?,
        notManagedPortfolios: [PortfolioDTO]?,
        managedPortfolios: [PortfolioDTO]?,
        notManagedRVStockAccounts: [StockAccountDTO]?,
        managedRVStockAccounts: [StockAccountDTO]?
    ) {
        self.isPb = isPb
        self.dto = dto
        self.accounts = dto?.accounts?.map(AccountEntity.init) ?? []
        self.cards = {
            guard let cards = dto?.cards else { return [] }
            var newCards: [CardEntity] = []
            for card in cards {
                let pan = card.formattedPAN ?? ""
                newCards.append(CardEntity(cardRepresentable: card,
                                           cardDataDTO: cardsData?[pan],
                                           cardBalanceDTO: cardBalances?[pan],
                                           temporallyOff: temporallyOffCards?[pan] != nil,
                                           inactiveCard: inactiveCards?[pan] != nil
                ))
            }
            return newCards
        }()
        self.stockAccounts = dto?.stockAccounts?.map(StockAccountEntity.init) ?? []
        self.deposits = dto?.deposits?.map(DepositEntity.init) ?? []
        self.loans = dto?.loans?.map(LoanEntity.init) ?? []
        self.pensions = dto?.pensions?.map(PensionEntity.init) ?? []
        self.funds = dto?.funds?.map(FundEntity.init) ?? []
        self.insuranceSavings = dto?.savingsInsurances?.map(InsuranceSavingEntity.init) ?? []
        self.protectionInsurances = dto?.protectionInsurances?.map(InsuranceProtectionEntity.init) ?? []
        self.notManagedPortfolios = notManagedPortfolios?.map(PortfolioEntity.init) ?? []
        self.managedPortfolios = managedPortfolios?.map(PortfolioEntity.init) ?? []
        self.notManagedPortfolioVariableIncome = notManagedRVStockAccounts?.map(StockAccountEntity.init) ?? []
        self.managedPortfolioVariableIncome = managedRVStockAccounts?.map(StockAccountEntity.init) ?? []
        self.savingProducts = dto?.savingProducts?.map(SavingProductEntity.init) ?? []
    }
    
    public convenience init(isPb: Bool?, dto: GlobalPositionDTO) {
        self.init(isPb: isPb, dto: dto, cardsData: nil, prepaidCards: nil, cardBalances: nil, temporallyOffCards: nil, inactiveCards: nil, notManagedPortfolios: nil, managedPortfolios: nil, notManagedRVStockAccounts: nil, managedRVStockAccounts: nil)
    }
}
