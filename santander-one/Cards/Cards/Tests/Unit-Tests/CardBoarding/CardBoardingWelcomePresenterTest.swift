import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Cards

final class CardBoardingWelcomePresenterTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    let cardsServiceInjector = CardsServiceInjector()
    private var presenter: CardBoardingWelcomePresenterProtocol!
    private var selectedCardEntity: CardEntity!
    private var view: CardBoardingWelcomeViewMock!
    
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.selectedCardEntity = globalPosition.cards[1]
        self.presenter = CardBoardingWelcomePresenter(dependenciesResolver: self.dependenciesResolver)
        self.view = CardBoardingWelcomeViewMock()
        self.presenter.view = self.view
    }
    
    override func tearDown() {
        self.dependenciesResolver.clean()
        self.presenter = nil
        self.selectedCardEntity = nil
        self.view = nil
    }
    
    func test_presenter_when_welcomeCreditCardTips_has_offers_then_tips_carousel_is_displayed() {
        // G
        self.dependenciesResolver.register(for: CardBoardingWelcomeUseCase.self, with: { resolver in
            return GetTipsUseCaseMock(dependenciesResolver: resolver)
        })
        // W
        self.presenter.viewDidLoad()
        // T
        waitForAssume(spying: self.view.isTipsCarouselVisible, expectedValue: true)
    }
    
    func test_presenter_when_welcomeCreditCardTips_has_no_offers_then_tips_carousel_is_not_displayed() {
        // G
        self.dependenciesResolver.register(for: CardBoardingWelcomeUseCase.self, with: { resolver in
            return GetTipsUseCaseEmptyMock(dependenciesResolver: resolver)
        })
        // W
        self.presenter.viewDidLoad()
        // T
        waitForAssume(spying: self.view.isTipsCarouselVisible, expectedValue: false)
    }
    
    func test_presenter_when_welcomeCreditCardTips_is_nil_then_tips_carousel_is_not_displayed() {
        // G
        self.dependenciesResolver.register(for: CardBoardingWelcomeUseCase.self, with: { resolver in
            return GetTipsUseCaseNilMock(dependenciesResolver: resolver)
        })
        // W
        self.presenter.viewDidLoad()
        // T
        waitForAssume(spying: self.view.isTipsCarouselVisible, expectedValue: false)
    }
    
    func test_presenter_when_CardBoardingUseCase_return_an_error_then_tips_carousel_is_not_displayed() {
        // G
        self.dependenciesResolver.register(for: CardBoardingWelcomeUseCase.self, with: { resolver in
            return GetTipsUseCaseErrorMock(dependenciesResolver: resolver)
        })
        // W
        self.presenter.viewDidLoad()
        // T
        waitForAssume(spying: self.view.isTipsCarouselVisible, expectedValue: false)
    }
}

private extension CardBoardingWelcomePresenterTest {
    func setDependencies() {
        self.setupCommonsDependencies()
        self.dependenciesResolver.register(for: CardBoardingWelcomeUseCase.self) { resolver in
            return CardBoardingWelcomeUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: self.selectedCardEntity!)
        }
    }
}

extension CardBoardingWelcomePresenterTest: RegisterCommonDependenciesProtocol { }
