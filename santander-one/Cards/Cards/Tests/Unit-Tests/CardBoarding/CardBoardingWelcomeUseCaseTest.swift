import XCTest
import CoreTestData
@testable import Cards
@testable import CoreFoundationLib

final class CardBoardingWelcomeUseCaseTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var debitCardEntity: CardEntity!
    private var creditCardEntity: CardEntity!
    private var appRepository = AppRepositoryMock()
    private var tipsMocked: [PullOfferTipEntity]?
    
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.debitCardEntity = globalPosition.cards.first(where: { $0.isDebitCard })
        self.creditCardEntity = globalPosition.cards.first(where: { $0.isCreditCard })
        self.tipsMocked = [PullOfferTipEntity(PullOffersConfigTipDTO(PullOffersHomeTipsContentDTO(title: "",
                                                                                                  desc: "",
                                                                                                  icon: "",
                                                                                                  tag: "",
                                                                                                  offerId: "",
                                                                                                  keyWords: [])),
                                              offer: OfferDTO(product: OfferProductDTO(identifier: "",
                                                                                       neverExpires: true,
                                                                                       transparentClosure: true,
                                                                                       description: "",
                                                                                       rulesIds: [],
                                                                                       iterations: 1,
                                                                                       banners: [],
                                                                                       bannersContract: [],
                                                                                       action: .none,
                                                                                       startDateUTC: Date(),
                                                                                       endDateUTC: Date())))]
    }

    override func tearDown() {
        self.dependenciesResolver.clean()

        self.debitCardEntity = nil
        self.creditCardEntity = nil
        self.tipsMocked = nil
    }
    
    func test_useCase_given_is_credit_card_and_welcomeCreditCardTips_isNil_then_tips_are_nil() {
        // G
        self.appRepository.welcomeCreditCardTips = nil
        // W
        let response = self.executeUseCase(with: self.creditCardEntity)
        // T
        XCTAssert(response.tips == nil)
    }
    
    func test_useCase_given_is_credit_card_and_welcomeCreditCardTips_isEmpty_then_tips_are_empty() {
        // G
        self.appRepository.welcomeCreditCardTips = []
        // W
        let response = self.executeUseCase(with: self.creditCardEntity)
        // T
        XCTAssert(response.tips?.count == 0)
    }
    
    func test_useCase_given_is_credit_card_and_welcomeCreditCardTips_has_tips_then_tips_has_values_and_the_same_size() {
        // G
        self.appRepository.welcomeCreditCardTips = self.tipsMocked
        // W
        let response = self.executeUseCase(with: self.creditCardEntity)
        // T
        XCTAssert(response.tips == self.appRepository.welcomeCreditCardTips)
    }
    
    func test_useCase_given_is_debit_card_and_welcomeDebitCardTips_isNil_then_tips_are_nil() {
        // G
        self.appRepository.welcomeDebitCardTips = nil
        // W
        let response = self.executeUseCase(with: self.debitCardEntity)
        // T
        XCTAssert(response.tips == nil)
    }
    
    func test_useCase_given_is_debit_card_and_welcomeDebitCardTips_isEmpty_then_tips_are_empty() {
        // G
        self.appRepository.welcomeDebitCardTips = []
        // W
        let response = self.executeUseCase(with: self.debitCardEntity)
        // T
        XCTAssert(response.tips?.count == 0)
    }
    
    func test_useCase_given_is_debit_card_and_welcomeDebitCardTips_has_tips_then_tips_has_values_and_the_same_size() {
        // G
        self.appRepository.welcomeDebitCardTips = self.tipsMocked
        // W
        let response = self.executeUseCase(with: self.debitCardEntity)
        // T
        XCTAssert(response.tips == self.appRepository.welcomeDebitCardTips)
    }
    
    func test_useCase_given_any_value_in_debit_or_credit_tips_when_useCase_is_executed_then_cannot_return_an_error() {
        // G
        self.appRepository.welcomeCreditCardTips = nil
        // W
        let input = GetCardBoardingWelcomeUseCaseInput(card: self.creditCardEntity)
        let useCase = CardBoardingWelcomeUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try? useCase.executeUseCase(requestValues: input).getErrorResult()
        // T
        XCTAssertNil(response)
    }
}

private extension CardBoardingWelcomeUseCaseTest {
    func setDependencies() {
        self.setupCommonsDependencies()
        self.dependenciesResolver.register(for: AppRepositoryProtocol.self) { (_) in
            return self.appRepository
        }
    }
    
    // swiftlint:disable force_try

    func executeUseCase(with card: CardEntity) -> GetCardBoardingWelcomeUseCaseOkOutput {
        let input = GetCardBoardingWelcomeUseCaseInput(card: card)
        let useCase = CardBoardingWelcomeUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try! useCase.executeUseCase(requestValues: input).getOkResult()
        return response
    }
    
    // swiftlint:enable force_try

}

extension CardBoardingWelcomeUseCaseTest: RegisterCommonDependenciesProtocol { }
