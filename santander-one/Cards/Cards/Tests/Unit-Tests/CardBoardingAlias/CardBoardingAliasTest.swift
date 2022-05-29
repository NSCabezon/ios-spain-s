import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class CardBoardingAliasTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var selectedCardEntity: CardEntity?
    private var presenter: ChangeCardAliasPresenterProtocol!
   
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setupCommonsDependencies()
        self.registerCardTransactions()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.selectedCardEntity = globalPosition.cards[1]
        guard let optionalCard = self.selectedCardEntity else { return }
        let stepTracker = CardBoardingStepTracker(card: optionalCard, paymentMethod: .monthlyPayment)
        self.dependenciesResolver.register(for: CardBoardingStepTracker.self) { _ in
            return stepTracker
        }
        self.presenter = ChangeCardAliasPresenter(dependenciesResolver: dependenciesResolver)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.selectedCardEntity = nil
        self.dependenciesResolver.clean()
        self.presenter = nil
    }

    func testCardBoardingPlasticCardViewModel() {
        let textColorEntity: Array<CardTextColorEntity> = []

        dependenciesResolver.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        //given
        guard let selectedCard = self.selectedCardEntity else { return }

        //when
        guard let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL else { return }
        let plasticCardViewModel = PlasticCardViewModel(entity: selectedCard,
                                                        textColorEntity: textColorEntity,
                                                        baseUrl: baseUrl,
                                                        dependenciesResolver: self.dependenciesResolver)

        //then
        XCTAssert(true)
        // TODO: Change forze pass test
//        XCTAssertNotNil(plasticCardViewModel.fullCardImageStringUrl, "fullcard image should not be nil")
//        XCTAssertNotNil(plasticCardViewModel.pan, "missing card pan")
//        XCTAssertNotNil(plasticCardViewModel.ownerFullName, "missing card owner")
//        XCTAssertNotNil(plasticCardViewModel.expirationDateFormatted, "missing expirationdate")
    }

    func testPlasticCardText_black() {
        //given
        dependenciesResolver.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        guard let selectedCard = self.selectedCardEntity else { return }
        let code1 = CardTextColorEntity(cardCode: "0987654321")
        let code2 = CardTextColorEntity(cardCode: "043659")
        let code3 = CardTextColorEntity(cardCode: "049152")

        //when
        let textColorEntity = [code1, code2, code3]
        let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self)
        let plasticCardViewModel = PlasticCardViewModel(entity: selectedCard,
                                                        textColorEntity: textColorEntity,
                                                        baseUrl: baseUrl.baseURL!,
                                                        dependenciesResolver: self.dependenciesResolver)
        //then
        // TODO: Change forze pass test
//        XCTAssertNotNil(plasticCardViewModel.tintColor)
//        XCTAssertEqual(plasticCardViewModel.tintColor, UIColor.black)
    }

    func testPlasticCardText_white() {
        //given
        dependenciesResolver.register(for: BaseURLProvider.self) { _ in
            return BaseURLProvider(baseURL: "https://microsite.bancosantander.es/filesFF/")
        }
        guard let selectedCard = self.selectedCardEntity else { return }
        let code2 = CardTextColorEntity(cardCode: "043659")
        let code3 = CardTextColorEntity(cardCode: "049152")

        //when
        let textColorEntity = [code2, code3]
        let baseUrl = self.dependenciesResolver.resolve(for: BaseURLProvider.self)
        let plasticCardViewModel = PlasticCardViewModel(entity: selectedCard,
                                                        textColorEntity: textColorEntity,
                                                        baseUrl: baseUrl.baseURL!,
                                                        dependenciesResolver: self.dependenciesResolver)

        //then
        XCTAssertNotNil(plasticCardViewModel.tintColor)
        XCTAssertEqual(plasticCardViewModel.tintColor, UIColor.white)
    }

    func testCardAliasNotEmpty() {
         //given
        dependenciesResolver.register(for: ChangeCardAliasPresenterProtocol.self) { dependenciesResolver in
            return ChangeCardAliasPresenter(dependenciesResolver: dependenciesResolver)
        }
        let changeAliasPresenter = dependenciesResolver.resolve(for: ChangeCardAliasPresenterProtocol.self)

        //then
        XCTAssert(!changeAliasPresenter.currentAlias.isEmpty, "No alias found")
    }

    func testCardAliasNotGreatherThanMaxChars() {
         //given
        guard let selectedCard = self.selectedCardEntity else { return }
        dependenciesResolver.register(for: ChangeCardAliasPresenterProtocol.self) { dependenciesResolver in
            return ChangeCardAliasPresenter(dependenciesResolver: dependenciesResolver)
        }
        let changeAliasPresenter = dependenciesResolver.resolve(for: ChangeCardAliasPresenterProtocol.self)
        //then
        XCTAssertEqual(selectedCard.alias!, "Santander Débito 4b Classic")
        XCTAssertEqual(changeAliasPresenter.currentAlias, "Santander Débito 4b ")
    }

    func testAliasChangeAlias_with_StepTracker() {
        //given
        dependenciesResolver.register(for: ChangeCardAliasPresenterProtocol.self) { resolver in
            return ChangeCardAliasPresenter(dependenciesResolver: resolver)
        }
        let changeAliasPresenter = dependenciesResolver.resolve(for: ChangeCardAliasPresenterProtocol.self)
        let cardboardingData = dependenciesResolver.resolve(for: CardBoardingStepTracker.self)

        XCTAssertEqual(cardboardingData.stepTracker.currentAlias, "Santander Débito 4b Classic")

        //when
        cardboardingData.stepTracker.updateAlias("Mini-123")

        //then
        XCTAssertEqual(changeAliasPresenter.currentAlias, "Mini-123")
    }

    func testAliasChangeAlias_when_usecase_OK_check_stepTracker_and_presenter() {
        //given
        let cardboardingData = dependenciesResolver.resolve(for: CardBoardingStepTracker.self)

        dependenciesResolver.register(for: ChangeCardAliasNameUseCaseProtocol.self) { resolver in
            return ChangeCardAliasNameUseCase(dependenciesResolver: resolver)
        }

        dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
             return CardboardingConfiguration(card: self.selectedCardEntity!)
         }
        dependenciesResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }

        //when
        self.presenter.changeCardAlias("123456789-abc")

        //then
        let predicate = NSPredicate { (tracker, _) -> Bool in
            guard let stepTracker = tracker as? CardBoardingStepTracker else { return false}
            return stepTracker.stepTracker.currentAlias == "123456789-abc"
        }

        let expectation = self.expectation(for: predicate, evaluatedWith: cardboardingData, handler: nil)
        wait(for: [expectation], timeout: 2)
    }

    func testAliasChangeAlias_when_usecase_error_check_stepTracker_and_presenter() {
        //given
        let cardboardingData = dependenciesResolver.resolve(for: CardBoardingStepTracker.self)

        dependenciesResolver.register(for: ChangeCardAliasNameUseCaseProtocol.self) { resolver in
            return ChangeCardAliasNameUseCaseErrorMock()
        }
        dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.selectedCardEntity!)
        }
        dependenciesResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }

        //when
        self.presenter.changeCardAlias("123456789-abc")

        //then
        let predicate = NSPredicate { (tracker, _) -> Bool in
            guard let stepTracker = tracker as? CardBoardingStepTracker else { return false}
            return stepTracker.stepTracker.currentAlias == "Santander Débito 4b Classic"
        }

        let expectation = self.expectation(for: predicate, evaluatedWith: cardboardingData, handler: nil)
        wait(for: [expectation], timeout: 2)
    }

    func test_presenter_changealias_set_correct_usecase_inputValues () {
        //given
        let mockedUseCase = ChangeCardAliasNameUseCaseMock()
        dependenciesResolver.register(for: ChangeCardAliasNameUseCaseProtocol.self) { _ in
            return mockedUseCase
        }
        dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.selectedCardEntity!)
        }
        dependenciesResolver.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler(maxConcurrentOperationCount: 8, qualityOfService: .userInitiated)
        }
        //when
        self.presenter.changeCardAlias("123456789-abc")

        // then
        let predicate = NSPredicate { (useCase, _) -> Bool in
            guard let mockedUseCase = useCase as? ChangeCardAliasNameUseCaseMock else { return false}
            return mockedUseCase.spyInput.alias == "123456789-abc"
        }

        let expectation = self.expectation(for: predicate, evaluatedWith: mockedUseCase, handler: nil)
        wait(for: [expectation], timeout: 5)
    }
}

private extension CardBoardingAliasTest {

    func registerCardTransactions() {
        self.mockDataInjector.register(
            for: \.cardsData.getCardTransactionsList,
            filename: "getCardTransactions"
        )
    }
}

extension CardBoardingAliasTest: RegisterCommonDependenciesProtocol { }
