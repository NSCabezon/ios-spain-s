import CoreFoundationLib
import SANLegacyLibrary

public class GlobalPositionMock: GlobalPositionRepresentable {
    public var clientSecondSurname: String?
    public var fullName: String
    public var notManagedPortfolioVariableIncome: [StockAccountEntity] = []
    public var managedPortfolioVariableIncome: [StockAccountEntity] = []
    public var clientBothSurnames: String?
    public var userCodeType: String?
    public var clientSurname: String?
    public var availableName: String?
    public var statusBoxCollapsed: [String : Bool] = [:]
    public var dto: GlobalPositionDTO?
    public var isPb: Bool? = true
    
    let cardsData: [String: CardDataDTO]
    let cardBalances: [String: CardBalanceDTO]
    let temporallyOffCards: [String: InactiveCardDTO]
    let inactiveCards: [String: InactiveCardDTO]
    
    public init(_ dto: GlobalPositionDTO,
                cardsData: [String: CardDataDTO],
                temporallyOffCards: [String: InactiveCardDTO],
                inactiveCards: [String: InactiveCardDTO],
                cardBalances: [String: CardBalanceDTO]) {
        self.dto = dto
        self.cardsData = cardsData
        self.temporallyOffCards = temporallyOffCards
        self.inactiveCards = inactiveCards
        self.cardBalances = cardBalances
        self.statusBoxCollapsed = [String: Bool]()
        self.userCodeType = ""
        self.fullName = ""
        self.clientSurname = ""
    }
    
    public init(_ dataProvider: MockGlobalPositionDataProvider) {
        self.dto = dataProvider.getGlobalPositionMock
        self.cardsData = dataProvider.getCardsInfoMock
        self.temporallyOffCards = [:]
        self.inactiveCards = [:]
        self.cardBalances = [:]
        self.statusBoxCollapsed = [:]
        self.userCodeType = ""
        self.fullName = ""
    }
    
    public var userId: String? {
        guard let userDataDTO = dto?.userDataDTO, let userType = userDataDTO.clientPersonType, let userCode = userDataDTO.clientPersonCode else {
            return nil
        }
        return userType + userCode
    }
    
    public lazy var loans: [LoanEntity] = {
        return dto?.loans?.map { LoanEntity($0) } ?? []
    }()

    public lazy var accounts: [AccountEntity] = {
        return dto?.accounts?.map { AccountEntity($0) } ?? []
    }()

    public lazy var cards: [CardEntity] = {
        let cards = dto?.cards?.map { card -> CardEntity in
            let trimmedPan = card.PAN?.notWhitespaces() ?? ""
            let cardData = cardsData[trimmedPan]
            let temporallyOff = temporallyOffCards[trimmedPan] != nil
            let inactiveCard = inactiveCards[trimmedPan] != nil
            let cardBalances = self.cardBalances[trimmedPan]
            return CardEntity(cardRepresentable: card,
                              cardDataDTO: cardData,
                              cardBalanceDTO: cardBalances,
                              temporallyOff: temporallyOff,
                              inactiveCard: inactiveCard)
        }
        return cards ?? []
    }()

    public lazy var stockAccounts: [StockAccountEntity] = {
        return dto?.stockAccounts?.map { StockAccountEntity($0) } ?? []
    }()

    public lazy var deposits: [DepositEntity] = {
        return dto?.deposits?.map { DepositEntity($0) } ?? []
    }()

    public lazy var pensions: [PensionEntity] = {
        return dto?.pensions?.map { PensionEntity($0) } ?? []
    }()

    public lazy var funds: [FundEntity] = {
        return dto?.funds?.map { FundEntity($0) } ?? []
    }()
    
    public lazy var savingProducts: [SavingProductEntity] = {
        return dto?.savingProducts?.map { SavingProductEntity($0) } ?? []
    }()

    public lazy var notManagedPortfolios: [PortfolioEntity] = {
        return []
    }()

    public lazy var managedPortfolios: [PortfolioEntity] = {
        return []
    }()

    public lazy var insuranceSavings: [InsuranceSavingEntity] = {
        return dto?.savingsInsurances?.map { InsuranceSavingEntity($0) } ?? []
    }()

    public lazy var protectionInsurances: [InsuranceProtectionEntity] = {
        return dto?.protectionInsurances?.map { InsuranceProtectionEntity($0) } ?? []
    }()

    public lazy var clientNameWithoutSurname: String? = {
        return dto?.clientNameWithoutSurname
    }()

    public lazy var clientBirthDate: Date? = {
        return dto?.clientBirthDate
    }()

    func productList<Property, ProductType: DTOInstantiable>(property: KeyPath<GlobalPositionDTO, [Property]?>) -> [ProductType] where ProductType.DTO == Property {
        return dto?[keyPath: property]?.map(ProductType.init) ?? []
    }
}
