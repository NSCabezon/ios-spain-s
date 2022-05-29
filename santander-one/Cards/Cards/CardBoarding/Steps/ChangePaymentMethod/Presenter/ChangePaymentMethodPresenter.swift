import Foundation
import CoreFoundationLib

protocol ChangePaymentMethodPresenterProtocol: AnyObject {
    var view: ChangePaymentMethodViewProtocol? { get set }
    func viewDidLoad()
    func didSelectBack()
    func didSelectNext()
    func didSelectNextSummaryView()
    func didPaymentMethodUpdated(_ paymentMethod: PaymentMethodCategory)
    func didSelectSkipStep()
    func didSelectRetry()
}

class ChangePaymentMethodPresenter {
    
    weak var view: ChangePaymentMethodViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var coordinator: CardBoardingCoordinatorProtocol {
        return dependenciesResolver.resolve(for: CardBoardingCoordinatorProtocol.self)
    }
    
    private var confirmCardModifyPaymentMethodUseCase: ConfirmCardModifyPaymentMethodUseCase {
        return ConfirmCardModifyPaymentMethodUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    private var configuration: CardboardingConfiguration {
        return self.dependenciesResolver.resolve(for: CardboardingConfiguration.self)
    }
    
    private var cardBoardingStepTracker: CardBoardingStepTracker {
        return self.dependenciesResolver.resolve(for: CardBoardingStepTracker.self)
    }
    
    private var selectedCard: CardEntity {
        return self.configuration.selectedCard
    }
    
    private var changePayment: ChangePaymentEntity? {
        return self.configuration.paymentMethod
    }
    
    private var currentPaymentMethod: PaymentMethodCategory? {
        return self.cardBoardingStepTracker.stepTracker.currentPaymentMethod
    }
    
    private var newPaymentMethod: PaymentMethodCategory?
}

extension ChangePaymentMethodPresenter: ChangePaymentMethodPresenterProtocol {
    
    func viewDidLoad() {
        guard let initialValue = self.currentPaymentMethod ?? self.configuration.paymentMethod?.paymentMethodCategory else { return }
        self.cardBoardingStepTracker.stepTracker.updatePaymentMethod(paymentMethod: initialValue)
        guard let changePayment = self.changePayment,
            let currentPaymentMethod = self.currentPaymentMethod else { return }
        self.setPaymentMethodsViews(changePayment: changePayment,
                                    paymentMethod: currentPaymentMethod)
        self.trackScreen()
    }
    
    func didSelectBack() {
        self.coordinator.didSelectGoBackwards()
    }
    
    func didSelectNext() {
        self.didSelectNextStep()
    }
    
    func didSelectNextSummaryView() {
        self.confirmPaymentMethodChange()
    }
    
    func didPaymentMethodUpdated(_ paymentMethod: PaymentMethodCategory) {
        self.newPaymentMethod = paymentMethod
    }
    
    func didSelectSkipStep() {
        self.coordinator.didSelectGoFoward()
    }
    
    func didSelectRetry() {
        self.confirmPaymentMethodChange()
    }
}

private extension ChangePaymentMethodPresenter {
    func setPaymentMethodsViews(changePayment: ChangePaymentEntity, paymentMethod: PaymentMethodCategory) {
        guard let paymentMethodAvailables = changePayment.paymentMethodListFiltered else { return }
        self.setHeaderView(paymentMethodAvailables)
        paymentMethodAvailables.forEach({ paymentEntity in
            switch paymentEntity.paymentMethodCategory {
            case .monthlyPayment:
                self.setMonthlyView(paymentMethod)
            case .deferredPayment:
                self.setDeferredViewModel(paymentEntity: paymentEntity, paymentMethod: paymentMethod)
            case .fixedFee:
                self.setFixedFeeViewModel(paymentEntity: paymentEntity, paymentMethod: paymentMethod)
            default:
                break
            }
        })
    }
    
    func setHeaderView(_ paymentMethods: [PaymentMethodEntity]) {
        let headerViewModel = PaymentMethodHeaderViewModel(paymentMethodsAvailables: paymentMethods)
        self.view?.setHeaderView(headerViewModel)
    }
    
    func setMonthlyView(_ paymentMethod: PaymentMethodCategory) {
        let monthlyViewModel = self.getMonthlyViewModel(paymentMethod)
        self.view?.setMonthlyView(monthlyViewModel)
    }
    
    func setDeferredViewModel(paymentEntity: PaymentMethodEntity, paymentMethod: PaymentMethodCategory) {
        if let deferredViewModel = self.getDeferredViewModel(paymentEntity: paymentEntity, paymentMethod: paymentMethod) {
            self.view?.setDeferredView(deferredViewModel)
        }
    }
    
    func setFixedFeeViewModel(paymentEntity: PaymentMethodEntity, paymentMethod: PaymentMethodCategory) {
        if let fixedFeeViewModel = self.getFixedFeeViewModel(paymentEntity: paymentEntity, paymentMethod: paymentMethod) {
            self.view?.setFixedFeeView(fixedFeeViewModel)
        }
    }
    
    func getMonthlyViewModel(_ paymentMethod: PaymentMethodCategory) -> PaymentMethodViewModel {
        let viewState: PaymentMethodViewState = paymentMethod == .monthlyPayment ? .selected : .deselected
        return PaymentMethodViewModel(
            title: "changeWayToPay_label_monthly",
            description: "cardBoarding_text_descriptionMonthly",
            viewState: viewState,
            paymentMethod: .monthlyPayment
        )
    }
    
    func getDeferredViewModel(paymentEntity: PaymentMethodEntity, paymentMethod: PaymentMethodCategory) -> PaymentMethodExpandableViewModel? {
        let amountValues = paymentEntity.getRangePercentage()
        guard amountValues.count > 0 else { return nil }
        var viewState: PaymentMethodViewState = .deselected
        var selectedAmount: AmountEntity? = AmountEntity(value: Decimal(amountValues[0]))
        if case .deferredPayment = paymentMethod {
            viewState = .selected
            selectedAmount = paymentMethod.value()
        }
        return PaymentMethodExpandableViewModel(
            title: "changeWayToPay_label_postpone",
            description: "cardBoarding_text_descriptionPostpone",
            selectAmountDescription: "cardBoarding_text_selectPercentage",
            minimunFee: "cardBoarding_label_minFee",
            placeHolder: "cardBoarding_label_percentage",
            selectedAmount: selectedAmount,
            amountRangeValues: amountValues,
            viewState: viewState,
            paymentMethod: .deferredPayment(selectedAmount)
        )
    }
    
    func getFixedFeeViewModel(paymentEntity: PaymentMethodEntity, paymentMethod: PaymentMethodCategory) -> PaymentMethodExpandableViewModel? {
        let amountValues = paymentEntity.getRangeAmount()
        guard amountValues.count > 0 else { return nil }
        var viewState: PaymentMethodViewState = .deselected
        var selectedAmount: AmountEntity? = AmountEntity(value: Decimal(amountValues[0]))
        if case .fixedFee = paymentMethod {
            viewState = .selected
            selectedAmount = paymentMethod.value()
        }
        return PaymentMethodExpandableViewModel(
            title: "changeWayToPay_label_fixedFee",
            description: "cardBoarding_text_descriptionFixedFee",
            selectAmountDescription: "cardBoarding_text_selectAmount",
            minimunFee: "cardBoarding_label_minFee",
            placeHolder: "cardBoarding_label_fixedFee",
            selectedAmount: selectedAmount,
            amountRangeValues: amountValues,
            viewState: viewState,
            paymentMethod: .fixedFee(selectedAmount)
        )
    }
    
    func didSelectNextStep() {
        if self.isPaymentMethodChanged() {
            self.presentSummary()
        } else {
            self.coordinator.didSelectGoFoward()
        }
    }
    
    func isPaymentMethodChanged() -> Bool {
        guard let newPaymentMethod = self.newPaymentMethod,
            let currentPaymentMethod = self.currentPaymentMethod else { return false }
        if self.currentPaymentMethod != newPaymentMethod {
            return true
        }
        guard let newAmount = newPaymentMethod.value(),
            let currentAmount = currentPaymentMethod.value(),
            newAmount.value != currentAmount.value else { return false }
        return true
    }
    
    func confirmPaymentMethodChange() {
        guard let input = self.getConfirmCardModifyPaymentMethodUseCaseInput() else { return }
        self.executeConfirmPaymentMethodChangeUseCase(with: input)
    }
    
    func getConfirmCardModifyPaymentMethodUseCaseInput() -> ConfirmCardModifyPaymentMethodUseCaseInput? {
        guard let changePayment = self.changePayment,
            let newCardPaymentMethod = self.newPaymentMethod,
            let newPaymentMethod = changePayment.getPaymentMethod(paymentCategory: newCardPaymentMethod)
            else { return nil }
        let newAmount = newCardPaymentMethod.value() ?? AmountEntity(value: 0)
        let input = ConfirmCardModifyPaymentMethodUseCaseInput(
            card: self.selectedCard,
            changePayment: changePayment,
            selectedPaymentMethod: newPaymentMethod,
            amount: newAmount
        )
        return input
    }
    
    func executeConfirmPaymentMethodChangeUseCase(with input: ConfirmCardModifyPaymentMethodUseCaseInput) {
        self.view?.showLoading()
        UseCaseWrapper(
            with: self.confirmCardModifyPaymentMethodUseCase.setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(),
            onSuccess: { [weak self] _ in
                guard let self = self, let newCardPaymentMethod = self.newPaymentMethod else { return }
                self.cardBoardingStepTracker.stepTracker.updatePaymentMethod(paymentMethod: newCardPaymentMethod)
                self.view?.dismissLoading(completion: {
                    self.coordinator.didSelectGoFoward()
                })
            },
            onError: { error in
                self.view?.dismissLoading(completion: {
                    self.view?.showError(error.getErrorDesc() ?? "")
                })
        })
    }
    
    func presentSummary() {
        guard let newPaymentMethod = self.newPaymentMethod else { return }
        self.view?.presentSummary(newPaymentMethod)
    }
}

extension ChangePaymentMethodPresenter: AutomaticScreenTrackable {
    var trackerPage: CardBoardingChangePaymentMethodPage {
        return CardBoardingChangePaymentMethodPage()
    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
