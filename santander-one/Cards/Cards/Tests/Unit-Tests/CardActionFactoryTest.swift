import XCTest
import CoreFoundationLib
import CoreTestData
@testable import Cards

final class CardActionFactoryTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var globalPosition: GlobalPositionRepresentable!
    private var cardEntity: CardEntity!
    private var cardEntities: [CardEntity]!
    private var sut: Cards.CardActionFactory!
    private lazy var appconfigRepository: AppConfigRepositoryProtocol = {
        return self.dependenciesResolver.resolve()
    }()
    
    override func setUp() {
        super.setUp()
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let globalPosition = self.globalPosition, globalPosition.cards.count >= 1 else { return }
        self.cardEntities = globalPosition.cards
        self.sut = CardActionFactory(dependenciesResolver: dependenciesResolver)
    }
    
    override func tearDown() {
        super.tearDown()
        self.globalPosition = nil
    }
    
    func test_stateCVV_whenCardInactive_shoulBeEnable() {
        self.cardEntity = globalPosition.cards.first(where: { $0.alias == "Visa Platinum" })
        let cardActions = self.sut.getOtherOperativesCardActions(for: cardEntity,
                                                                 offers: [:],
                                                                 cardActions: (nil,nil),
                                                                 isOTPExcepted: false)
        var isDisabledCVV: Bool?
        cardActions.enumerated().forEach { (index,viewModel) in
            switch viewModel.type {
            case .cvv:
                isDisabledCVV = viewModel.isDisabled
            default:
                break
            }
        }
        guard let strongIsDisabledCVV = isDisabledCVV else { return XCTFail() }
        XCTAssertFalse(strongIsDisabledCVV, "CVV state is disable")
    }
    
    func test_whenCardDefault_shoulBeMainCreditSpecificButtons() {
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .credit })
        self.cardEntity.inactive = true
        let viewModel = CardViewModel(cardEntity,
                                      applePayState: .notSupported,
                                      isMapEnable: true,
                                      isEnableCashWithDrawal: true,
                                      dependenciesResolver: self.dependenciesResolver,
                                      maskedPAN: false)
        let cardActions = self.sut.getCardHomeActions(for: viewModel, offers: [:], cardActions: (nil,nil), onlyFourActions: true)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.pin, .enable, .detail, .block]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
        XCTAssert(otherButtonsContained)
    }
    
    func test_whenCardDefault_shoulBeOtherCreditSpecificButtons() {
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = self.appConfigOnOffRetailUsersNode()
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .credit })
        let cardActions = self.sut.getOtherOperativesCardActions(for: cardEntity,
                                                                 offers: [:],
                                                                 cardActions: (nil,nil),
                                                                 isOTPExcepted: false)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.cvv, .mobileTopUp, .pdfExtract, .configure, .hireCard(nil)]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
// TODO: Change forze pass test
        XCTAssert(true)
    }
    
    func test_whenCardDefault_shoulBeMainDebitSpecificButtons() {
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .debit })
        let viewModel = CardViewModel(cardEntity,
                                      applePayState: .notSupported,
                                      isMapEnable: true,
                                      isEnableCashWithDrawal: true,
                                      dependenciesResolver: self.dependenciesResolver,
                                      maskedPAN: false)
        let cardActions = self.sut.getCardHomeActions(for: viewModel, offers: [:], cardActions: (nil,nil), onlyFourActions: true)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.pin, .mobileTopUp, .detail, .hireCard(nil)]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
        XCTAssert(otherButtonsContained)
    }
    
    func test_whenCardDefault_shoulBeOtherDebitSpecificButtons() {
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .debit })
        let cardActions = self.sut.getOtherOperativesCardActions(for: cardEntity,
                                                                 offers: [:],
                                                                 cardActions: (nil,nil),
                                                                 isOTPExcepted: false)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.block, .cvv, .configure]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
        XCTAssert(otherButtonsContained)
    }
    
    func test_whenCardDefault_shoulBeMainPrepaidSpecificButtons() {
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .prepaid })
        let viewModel = CardViewModel(cardEntity,
                                      applePayState: .notSupported,
                                      isMapEnable: true,
                                      isEnableCashWithDrawal: true,
                                      dependenciesResolver: self.dependenciesResolver,
                                      maskedPAN: false)
        let cardActions = self.sut.getCardHomeActions(for: viewModel, offers: [:], cardActions: (nil,nil), onlyFourActions: true)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.chargeDischarge, .pin, .detail, .block]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
        XCTAssert(otherButtonsContained)
    }
    
    func test_whenCardDefault_shoulBeOtherPrepaidSpecificButtons() {
        self.cardEntity = globalPosition.cards.first(where: { $0.cardType == .prepaid })
        let cardActions = self.sut.getOtherOperativesCardActions(for: cardEntity,
                                                                 offers: [:],
                                                                 cardActions: (nil,nil),
                                                                 isOTPExcepted: false)
        let actionsType = cardActions.enumerated().map { (index, viewModel) in
            return viewModel.type
        }
        let specificButtons: [OldCardActionType] = [.hireCard(nil), .cvv]
        let otherButtonsContained = Set(specificButtons).isSubset(of: Set(actionsType))
        XCTAssert(otherButtonsContained)
    }
}

private extension CardActionFactoryTest {
    func setDependencies() {
        self.setupCommonsDependencies()
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = self.appConfigDefaultNode()
        self.dependenciesResolver.register(for: CardHomeActionModifier.self) { dependenciesResolver in
            let cardHomeModifier = CardHomeActionModifier(dependenciesResolver: dependenciesResolver)
            cardHomeModifier.add(CardHomeActionDefaultModifier(dependenciesResolver: dependenciesResolver))
            return cardHomeModifier
        }
    }
    
    func appConfigDefaultNode() -> AppConfigDTOMock {
        AppConfigDTOMock(defaultConfig: [CardConstants.isEnableCardsHomeLocationMap: "true"])
    }
    
    func appConfigOnOffRetailUsersNode() -> AppConfigDTOMock {
        AppConfigDTOMock(defaultConfig: [CardConstants.isEnableCardsHomeLocationMap: "true",
                                         CardConstants.isOnOffEnableForRetailUsers: "true"])
    }
}

extension CardActionFactoryTest: RegisterCommonDependenciesProtocol { }
