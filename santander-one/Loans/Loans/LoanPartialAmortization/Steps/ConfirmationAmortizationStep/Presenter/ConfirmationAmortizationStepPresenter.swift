import CoreFoundationLib
import Foundation
import Operative
import SANLegacyLibrary
import CoreDomain

public protocol ConfirmationAmortizationStepPresenterModifierProtocol: ConfirmationAmortizationStepPresenterProtocol {}

public protocol ConfirmationAmortizationStepPresenterProtocol: OperativeConfirmationPresenterProtocol {
    var view: ConfirmationAmortizationStepViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectClose()
    func didSelectBack()
    func modifyAmount()
}

open class ConfirmationAmortizationStepPresenter {
    public weak var view: ConfirmationAmortizationStepViewProtocol?
    public let dependenciesResolver: DependenciesResolver
    private var timeManager: TimeManager
    public var amortizationViewModel: ConfirmationAmortizationViewModel?
    public var number: Int = 0
    public var isBackButtonEnabled: Bool = true
    public var isCancelButtonEnabled: Bool = true
    public var container: OperativeContainerProtocol?

    public lazy var operativeData: LoanPartialAmortizationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.timeManager = dependenciesResolver.resolve()
    }

    open func setupConfirmationItems() { }

    open func updateViewState() {} // Overridden in Spain app
}

extension ConfirmationAmortizationStepPresenter: ConfirmationAmortizationStepPresenterProtocol {
    public func viewDidLoad() {
        let pending = self.calculatePendingCapital()
        self.getInfo(pendingAmount: pending)
        trackScreen()
    }

    public func viewWillAppear() {
        self.container?.progressBarAlpha(1)
        self.updateViewState()
    }

    public func modifyAmount() {
        self.container?.back(to: SelectAmortizationStepPresenter.self)
    }

    public func didSelectClose() {
        self.container?.close()
    }

    public func didSelectBack() {
        self.container?.back(to: SelectAmortizationStepPresenter.self)
    }

    func getInfo(pendingAmount: AmountEntity?) {
        guard let partialLoan = operativeData.partialAmortization,
              let partialLoanValidation = operativeData.partialLoanAmortizationValidation,
              let amortizationType = operativeData.amortizationType,
              let selectedAmount = operativeData.amortizationAmount,
              let loanDetail = operativeData.selectedLoanDetail
        else { return }
        self.amortizationViewModel = ConfirmationAmortizationViewModel(
            self.operativeData.selectedLoan,
            loanDetail: loanDetail,
            partialLoan: partialLoan,
            loanValidation: partialLoanValidation,
            amountTypeAmortization: amortizationType,
            amountSelected: selectedAmount,
            timeManager: self.timeManager,
            selectedAccount: self.operativeData.account,
            phoneNumber: self.operativeData.signatureSupportPhone,
            pendingAmount: pendingAmount,
            operativeData: self.operativeData)
        self.container?.handler?.showOperativeLoading { [weak self] in
            guard let amortizationType = self?.operativeData.amortizationType,
                  let partialAmortization = self?.operativeData.partialAmortization,
                  let amount = self?.operativeData.amortizationAmount else { return }
            let input = ValidateLoanPartialAmortizationUseCaseInput(loanPartialAmortization: partialAmortization,
                                                                    amount: amount,
                                                                    amortizationType: amortizationType)
            self?.validateLoan(input)
        }
    }

    public func didSelectContinue() {
        self.container?.stepFinished(presenter: self)
    }
}

private extension ConfirmationAmortizationStepPresenter {
    var baseUrlProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }

    var coordinator: LoanPartialAmortizationFinishingCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: LoanPartialAmortizationFinishingCoordinatorProtocol.self)
    }

    var loanEntity: LoanRepresentable {
        self.operativeData.selectedLoan
    }

    private func calculatePendingCapital() -> AmountEntity? {
        guard let pendingAmount = operativeData.partialAmortization?.pendingAmount?.value.map(abs),
              let selectedAmount = operativeData.amortizationAmount?.value.map(abs),
              let currencyRepresentable = operativeData.partialAmortization?.pendingAmount?.currencyRepresentable else { return nil }
        let rounding = NSDecimalNumberHandler(roundingMode: .down,
                                              scale: 2,
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: false)
        let decimalCurrentPendingAmount = (pendingAmount as NSDecimalNumber)
            .decimalValue
        let decimalSelectedAmount = (selectedAmount as NSDecimalNumber)
            .decimalValue
        let decimalPendingAmount = decimalCurrentPendingAmount - decimalSelectedAmount
        guard let currencyDTO = currencyRepresentable as? CurrencyDTO else { return nil }
        let pending = AmountEntity(AmountDTO(value: decimalPendingAmount,
                                             currency: currencyDTO))
        self.operativeData.pendingCapital = pending
        self.container?.save(self.operativeData)
        return pending
    }

    func validateLoan(_ input: ValidateLoanPartialAmortizationUseCaseInput) {
        guard let container = self.container else { return }
        let loan = self.operativeData.selectedLoan
        let useCase = self.dependenciesResolver.resolve(for: ValidateLoanPartialAmortizationUseCaseProtocol.self)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                guard let strongSelf = self,
                      let signatureDTO = result.loanValidation.signatureRepresentable as? SignatureDTO else { return }
                strongSelf.container?.handler?.hideOperativeLoading {
                    strongSelf.operativeData.partialLoanAmortizationValidation = result.loanValidation
                    strongSelf.container?.save(signatureDTO)
                    strongSelf.container?.save(strongSelf.operativeData)
                    strongSelf.view?.loadView(strongSelf.amortizationViewModel)
                    strongSelf.setupConfirmationItems()
                }
            }
            .onError { [weak self] _ in
                self?.container?.handler?.hideOperativeLoading {
                    self?.container?.showGenericError()
                }
            }
    }
}

extension ConfirmationAmortizationStepPresenter: AutomaticScreenTrackable {
    public var trackerPage: LoanPartialAmortizationConfirmationPage {
        return LoanPartialAmortizationConfirmationPage()
    }

    public var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
