import XCTest
import CoreTestData
import CoreFoundationLib
import UnitTestCommons
import SANLegacyLibrary
@testable import Cards

final class CardBoardingChangePaymentMethodPresenterTest: XCTestCase {
    let mockDataInjector = MockDataInjector()
    let dependenciesResolver = DependenciesDefault()
    private var presenter: ChangePaymentMethodPresenterProtocol!
    private var selectedCardEntity: CardEntity!
    private var view: CardBoardingChangePaymentMethodViewMock!
    private var configuration: CardboardingConfiguration!
    private var cardBoardingStepTracker: CardBoardingStepTracker!
    private var stepTracker: StepTracker!
    private var coordinator: CardBoardingProtocolMock!
    let cardsServiceInjector = CardsServiceInjector()
    
    override func setUp() {
        cardsServiceInjector.inject(injector: mockDataInjector)
        self.setDependencies()
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard globalPosition.cards.count >= 1 else { return }
        self.selectedCardEntity = globalPosition.cards.first(where: { $0.isCreditCard })
        self.presenter = ChangePaymentMethodPresenter(dependenciesResolver: self.dependenciesResolver)
        self.view = CardBoardingChangePaymentMethodViewMock()
        self.presenter.view = self.view
        self.coordinator = CardBoardingProtocolMock()
    }
    
    override func tearDown() {
        self.dependenciesResolver.clean()
        self.presenter = nil
        self.selectedCardEntity = nil
        self.view = nil
    }
    
    func test_presenter_given_is_monthly_available_when_viewDidLoad_then_header_description_is_descriptionPaymentMethod_key() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment])
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.headerViewDescription, expectedValue: "cardBoarding_text_descriptionPaymentMethod")
        let expectation2 = Assume(spying: self.view.isMonthlyViewVisible, expectedValue: true)
        // T
        wait(for: [expectation, expectation2], timeout: 1)
    }
    
    func test_presenter_given_is_monthly_not_available_when_viewDidLoad_then_header_description_is_descriptionPaymentMethodNoMonthly_key() {
        // G
        self.setPaymentMethods(paymentMethods: [.deferredPayment, .fixedFee], currentPaymentMethod: .deferredPayment)
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.headerViewDescription, expectedValue: "cardBoarding_text_descriptionPaymentMethodNoMonthly")
        let expectation2 = Assume(spying: self.view.isMonthlyViewVisible, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isDeferredViewVisible, expectedValue: true)
        let expectation4 = Assume(spying: self.view.isFixedFeeViewVisible, expectedValue: true)
        // T
        wait(for: [expectation, expectation2, expectation3, expectation4], timeout: 1)
    }
    
    func test_presenter_given_is_monthly_the_currentPaymentMethod_when_viewDidLoad_then_monthlyView_appears_as_selected() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .monthlyPayment)
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.isMonthlySelected, expectedValue: true)
        let expectation2 = Assume(spying: self.view.isDeferredSelected, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isFixedFeeSelected, expectedValue: false)
        // T
        wait(for: [expectation, expectation2, expectation3], timeout: 1)
    }
    
    func test_presenter_given_is_deferred_the_currentPaymentMethod_when_viewDidLoad_then_deferredView_appears_as_selected() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .deferredPayment)
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.isDeferredSelected, expectedValue: true)
        let expectation2 = Assume(spying: self.view.isMonthlySelected, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isFixedFeeSelected, expectedValue: false)
        // T
        wait(for: [expectation, expectation2, expectation3], timeout: 1)
    }
    
    func test_presenter_given_is_fixedFee_the_currentPaymentMethod_when_viewDidLoad_then_fixedFeeView_appears_as_selected() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .fixedFee)
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.isFixedFeeSelected, expectedValue: true)
        let expectation2 = Assume(spying: self.view.isMonthlySelected, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isDeferredSelected, expectedValue: false)
        // T
        wait(for: [expectation, expectation2, expectation3], timeout: 1)
    }
    
    func test_presenter_given_is_deferred_the_currentPaymentMethod_when_viewDidLoad_then_selectedValue_isCorrect() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .deferredPayment)
        let deferredMethod = self.getDeferredMethod()
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.isDeferredSelected, expectedValue: true)
        let expectation2 = Assume(spying: self.view.isMonthlySelected, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isFixedFeeSelected, expectedValue: false)
        let expectation4 = Assume(spying: self.view.selectedAmount, expectedValue: deferredMethod.feeAmount?.value)
        // T
        wait(for: [expectation, expectation2, expectation3, expectation4], timeout: 1)
    }
    
    func test_presenter_given_is_fixedFee_the_currentPaymentMethod_when_viewDidLoad_then_selectedValue_isCorrect() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .fixedFee)
        let fixedFeeMethod = self.getFixedFeeMethod()
        // W
        self.presenter.viewDidLoad()
        let expectation = Assume(spying: self.view.isFixedFeeSelected, expectedValue: true)
        let expectation2 = Assume(spying: self.view.isMonthlySelected, expectedValue: false)
        let expectation3 = Assume(spying: self.view.isDeferredSelected, expectedValue: false)
        let expectation4 = Assume(spying: self.view.selectedAmount, expectedValue: fixedFeeMethod.feeAmount?.value)
        // T
        wait(for: [expectation, expectation2, expectation3, expectation4], timeout: 1)
    }
    
    func test_presenter_given_paymentMethod_is_not_changed_when_press_next_step_then_use_case_is_not_executed() {
        // G
        self.setPaymentMethods(paymentMethods: [.monthlyPayment, .deferredPayment, .fixedFee], currentPaymentMethod: .fixedFee)
        // W
        self.presenter.didSelectNext()
        // T
        waitForAssume(spying: self.coordinator.isGoingForward, expectedValue: false)
    }
}

private extension CardBoardingChangePaymentMethodPresenterTest {
    func setDependencies() {
        self.setupCommonsDependencies()
        self.dependenciesResolver.register(for: ConfirmCardModifyPaymentMethodUseCase.self) { resolver in
            return ConfirmCardModifyPaymentMethodUseCase(dependenciesResolver: resolver)
        }
        self.dependenciesResolver.register(for: CardboardingConfiguration.self) { _ in
            return self.configuration
        }
        self.dependenciesResolver.register(for: CardBoardingStepTracker.self) { _ in
            return self.cardBoardingStepTracker
        }
        self.dependenciesResolver.register(for: StepTracker.self) { _ in
            return self.stepTracker
        }
        self.dependenciesResolver.register(for: CardBoardingCoordinatorProtocol.self) { _ in
            return CardBoardingProtocolMock()
        }
    }
    
    func setPaymentMethods(paymentMethods: [PaymentMethodType], currentPaymentMethod: PaymentMethodType = .monthlyPayment) {
        let paymentMethods = self.setPaymentMethodList(with: paymentMethods)
        let changePayment = self.getChangePayment(with: paymentMethods, currentPaymentMethod: currentPaymentMethod)
        let configuration =  CardboardingConfiguration(card: self.selectedCardEntity)
        configuration.paymentMethod = changePayment
        self.configuration = configuration
        self.cardBoardingStepTracker = CardBoardingStepTracker(card: self.selectedCardEntity, paymentMethod: changePayment.paymentMethodCategory)
        self.stepTracker = StepTracker(aliasStep: AliasTracker(alias: ""),
                                       applePayTracker: ApplePayTracker(applePayState: nil),
                                       paymentMethodTracker: PaymentMethodTracker(paymentMethod: changePayment.paymentMethodCategory))
    }
    
    func setPaymentMethodList(with methods: [PaymentMethodType]) -> [PaymentMethodDTO] {
        var paymentMethods: [PaymentMethodDTO] = []
        methods.forEach { paymentMethodType in
            switch paymentMethodType {
            case .monthlyPayment:
                paymentMethods.append(self.getMonthlyMethod())
            case .deferredPayment:
                paymentMethods.append(self.getDeferredMethod())
            case .fixedFee:
                paymentMethods.append(self.getFixedFeeMethod())
            default:
                break
            }
        }
        return paymentMethods
    }
    
    func getChangePayment(with paymentMethodList: [PaymentMethodDTO], currentPaymentMethod: PaymentMethodType) -> ChangePaymentEntity {
        var changePaymentDTO = ChangePaymentDTO()
        changePaymentDTO.paymentMethodList = paymentMethodList
        changePaymentDTO.currentPaymentMethod = currentPaymentMethod
        return ChangePaymentEntity(changePaymentDTO)
    }
    
    func getMonthlyMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .monthlyPayment
        return paymentMethodDTO
    }
    
    func getDeferredMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .deferredPayment
        paymentMethodDTO.feeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.incModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.maxModeAmount = AmountDTO(value: 450, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minAmortAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        return paymentMethodDTO
    }
    
    func getFixedFeeMethod() -> PaymentMethodDTO {
        var paymentMethodDTO = PaymentMethodDTO()
        paymentMethodDTO.paymentMethod = .fixedFee
        paymentMethodDTO.feeAmount = AmountDTO(value: 50, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.incModeAmount = AmountDTO(value: 50, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.maxModeAmount = AmountDTO(value: 500, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minAmortAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        paymentMethodDTO.minModeAmount = AmountDTO(value: 25, currency: CurrencyDTO(currencyName: "", currencyType: .eur))
        return paymentMethodDTO
    }
}

extension CardBoardingChangePaymentMethodPresenterTest: RegisterCommonDependenciesProtocol { }
