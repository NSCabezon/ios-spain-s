import CoreFoundationLib
import Foundation
import Operative
import CoreDomain
import SANLegacyLibrary

protocol SelectAmortizationStepPresenterProtocol: OperativeStepPresenterProtocol, UpdatableTextFieldDelegate {
    var view: SelectAmortizationStepViewProtocol? { get set }
    func viewDidLoad()
    func didSelectClose()
    func didSelectBack()
    func continueButtonPressed()
    func newOptionSelected(_ option: PartialAmortizationTypeRepresentable)
}

final class SelectAmortizationStepPresenter {
    weak var view: SelectAmortizationStepViewProtocol?
    private var optionSelected: PartialAmortizationTypeRepresentable?
    private let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var currentAmount: Decimal?
    lazy var operativeData: LoanPartialAmortizationOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension SelectAmortizationStepPresenter {
    var baseUrlProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }

    var coordinator: LoanPartialAmortizationFinishingCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: LoanPartialAmortizationFinishingCoordinatorProtocol.self)
    }

    func setupHeader() {
        let loan = self.operativeData.selectedLoan
        guard let amountDto = loan.currentBalanceAmountRepresentable as? AmountDTO else {
            self.view?.setupHeader(SelectAmortizationHeaderViewModel(name: loan.alias ?? "", pending: ""))
            return
        }
        let pendingAmount = AmountEntity(amountDto)
        self.view?.setupHeader(SelectAmortizationHeaderViewModel(name: loan.alias ?? "", pending: pendingAmount.getAbsFormattedAmountUI()))
    }

    func saveInfoAndNextStep(amountEntity: AmountEntity, type: PartialAmortizationTypeRepresentable, partialLoan: LoanPartialAmortizationRepresentable, validation: LoanValidationRepresentable) {
        self.container?.handler?.hideOperativeLoading {
            self.operativeData.amortizationAmount = amountEntity.dto
            self.operativeData.amortizationType = type
            self.operativeData.partialAmortization = partialLoan
            self.operativeData.partialLoanAmortizationValidation = validation
            self.operativeData.newMortgageLawConditionsReviewed = false
            self.container?.save(self.operativeData)
            self.container?.stepFinished(presenter: self)
        }
    }
}

extension SelectAmortizationStepPresenter: SelectAmortizationStepPresenterProtocol {
    var loanEntity: LoanRepresentable? {
        self.operativeData.selectedLoan
    }

    func viewDidLoad() {
        self.setupHeader()
        self.trackScreen()
    }

    func didSelectClose() {
        self.container?.close()
    }

    func didSelectBack() {
        self.container?.dismissOperative()
    }

    func continueButtonPressed() {
        guard
            let optionSelected = optionSelected,
            let amount = currentAmount
        else {
            self.container?.showGenericError()
            return
        }
        let loan = self.operativeData.selectedLoan
        let amountEntity = AmountEntity(value: amount)
        self.container?.handler?.showOperativeLoading { [weak self] in
            guard let self = self else { return }
            let useCase = self.dependenciesResolver.resolve(for: PrevalidatePartialAmortizationUseCaseProtocol.self)
            let requestValues = PrevalidatePartialAmortizationUseCaseInput(loan: loan, amount: amountEntity.dto, amortizationType: optionSelected)
            Scenario(useCase: useCase, input: requestValues)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] result in
                    guard let self = self else { return }
                    let partialLoan = result.partialLoan
                    let partialLoanAmortizationValidation = result.loanValidation
                    self.saveInfoAndNextStep(amountEntity: amountEntity, type: optionSelected, partialLoan: partialLoan, validation: partialLoanAmortizationValidation)
                }
                .onError { [weak self] error in
                    self?.container?.handler?.hideOperativeLoading {
                        self?.view?.showErrorDialogWith(error: error.getErrorDesc() ?? localized("generic_error_alert_text"))
                    }
                }
        }
    }

    func newOptionSelected(_ option: PartialAmortizationTypeRepresentable) {
        switch option {
        case .decreaseTime:
            self.trackEvent(.advanceExpiration, parameters: [:])
        case .decreaseFee:
            self.trackEvent(.decreaseFee, parameters: [:])
        default:
            break
        }
        self.optionSelected = option
        self.validate()
    }

    func validate() {
        guard let option = optionSelected else {
            self.view?.disableContinueButton()
            return
        }
        switch self.optionSelected {
        case .decreaseTime:
            self.currentAmount = Decimal(string: self.view?.advanceTextfield.text ?? "")
        case .decreaseFee:
            self.currentAmount = Decimal(string: self.view?.decreaseTextfield.text ?? "")
        default:
            self.currentAmount = nil
        }
        if self.currentAmount == nil {
            self.view?.disableContinueButton()
        } else {
            self.view?.enableContinueButton()
        }
    }
}

extension SelectAmortizationStepPresenter: UpdatableTextFieldDelegate {
    func updatableTextFieldDidUpdate() {
        self.validate()
    }
}

extension SelectAmortizationStepPresenter: AutomaticScreenActionTrackable {
    var trackerPage: LoanPartialAmortizationTypePage {
        return LoanPartialAmortizationTypePage()
    }

    var trackerManager: TrackerManager {
        return self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
