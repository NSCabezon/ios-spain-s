import Operative
import CoreFoundationLib
import UI

protocol InternalTransferAmountAndTypeSelectorPresenterProtocol: OperativeStepPresenterProtocol, ValidatableFormPresenterProtocol {
    var view: InternalTransferAmountAndTypeSelectorViewProtocol? { get set }
    func viewDidLoad()
    func changeAccountSelected()
    func continueSelected()
    func loaded()
    func close()
    func faqs()
    func trackFaqEvent(_ question: String, url: URL?)
    func differenceOfDaysToDeferredTransfers() -> Int
}

final class InternalTransferAmountAndTypeSelectorPresenter {
    weak var view: InternalTransferAmountAndTypeSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var fields: [ValidatableField] = []

    lazy var operativeData: InternalTransferOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    private lazy var internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self)
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension InternalTransferAmountAndTypeSelectorPresenter: InternalTransferAmountAndTypeSelectorPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.validatableFieldChanged()
        self.setPeriodicityModel()
        self.setViewsVisibility()
    }
    
    func changeAccountSelected() {
        self.container?.back(
            to: InternalTransferAccountSelectorPresenter.self,
            creatingAt: 0,
            step: InternalTransferAccountSelectorStep(dependenciesResolver: dependenciesResolver)
        )
    }
    
    func continueSelected() {
        guard let view = self.view else { return }
        var type: ValidateInternalTransferTypeInput
        switch view.type {
        case .now:
            type = .now
        case .day:
            if self.isEnabledValidateInternalTransfer() {
                type = .day(date: view.oneDayDate)
            } else {
                self.continueWihtoutValidateInternalTransfer()
                return
            }
        case .periodic:
            if self.isEnabledValidateInternalTransfer() {
                type = .day(date: view.oneDayDate)
            } else {
                self.continueWihtoutValidateInternalTransfer()
                return
            }
            let periodicity = view.periodicPeriodicity?.internalTransferPeriodicPeriodicityType ?? .month
            let emission: ValidateInternalTransferPeriodicEmissionType
            switch view.periodicEmissionDate {
            case .next, .none:
                emission = .next
            case .previous:
                emission = .previous
            }
            type = .periodic(start: view.periodicStartDate, end: view.periodicEndDate, isEnd: view.periodicEndDateNever, periodicity: periodicity, emission: emission)
        }
        let input = ValidateInternalTransferUseCaseInput(amount: view.amount, concept: view.concept, time: type, selectedAccount: self.operativeData.selectedAccount, destinationAccount: self.operativeData.destinationAccount)
        self.view?.showLoading { [weak self] in
            self?.validateData(input: input)
        }
    }
    
    private func validateData(input: ValidateInternalTransferUseCaseInput) {
        UseCaseWrapper(
            with: self.dependenciesResolver.resolve(for: ValidateInternalTransferUseCase.self).setRequestValues(requestValues: input),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.view?.dismissLoading {
                    self.operativeData.scheduledTransfer = result.scheduledTransfer
                    self.operativeData.internalTransfer = result.internalTransfer
                    self.operativeData.time = result.time
                    self.operativeData.amount = result.amount
                    self.operativeData.concept = result.concept
                    self.container?.save(result.scaEntity)
                    self.container?.rebuildSteps()
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] errorResult in
                self?.view?.dismissLoading {
                    guard let self = self else { return }
                    guard case let .error(transferError) = errorResult,
                        let error = (transferError as? InternalTransferError)?.error else {
                        self.showErrorMessage(key: errorResult.getErrorDesc() ?? "")
                        return
                    }
                    guard case let .invalidAmount(key) = error else { return }
                    self.view?.updateContinueAction(false)
                    self.view?.showInvalidAmount(localized(key))
                }
            }
        )
    }
    
    func showErrorMessage(key: String) {
        self.view?.showOldDialog(
            title: nil,
            description: localized(key),
            acceptAction: DialogButtonComponents(titled: localized("generic_button_accept"), does: nil),
            cancelAction: nil,
            isCloseOptionAvailable: false
        )
    }
    
    func loaded() {
        let type: InternalTransferDateTypeFilledViewModel
        switch self.operativeData.time {
        case .now, .none:
            type = .now
        case .day(let date):
            type = .day(date: date)
        case .periodic(let startDate, let endDate, let periodicity, let workingDayIssue):
            let periodicityModel: InternalTransferPeriodicityTypeViewModel
            let emissionModel: InternalTransferEmissionTypeViewModel
            let endDateModel: InternalTransferPeroidicEndDateTypeFilledViewModel
            switch endDate {
            case .never:
                endDateModel = .never
            case .date(let date):
                endDateModel = .date(date)
            }
            switch periodicity {
            case .monthly:
                periodicityModel = .month
            case .quarterly:
                periodicityModel = .quarterly
            case .biannual:
                periodicityModel = .semiannual
            case .weekly:
                periodicityModel = .weekly
            case .bimonthly:
                periodicityModel = .bimonthly
            case .annual:
                periodicityModel = .annual
            }
            switch workingDayIssue {
            case .laterDay:
                emissionModel = .next
            case .previousDay:
                emissionModel = .previous
            }
            type = .periodic(start: startDate, end: endDateModel, periodicity: periodicityModel, emission: emissionModel)
        }
        guard let selectedAccount = self.operativeData.selectedAccount else { return }
        let viewModel = SelectedAccountHeaderViewModel(account: selectedAccount, action: self.changeAccountSelected, dependenciesResolver: self.dependenciesResolver)
        self.view?.set(accountViewModel: viewModel, amount: self.operativeData.amount?.getFormattedValue(), concept: self.operativeData.concept, type: type)
    }
    
    func close() {
        self.container?.close()
    }

    func faqs() {
        let faqs = self.operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.trackerManager.trackScreen(screenId: InternalTransferFaqPage().page, extraParameters: [:])
        self.view?.showFaqs(faqs)
    }

    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("transfer_faqs"), object: nil, userInfo: ["parameters": dic])
    }
    
    func differenceOfDaysToDeferredTransfers() -> Int {
        guard let internalTransferModifier = self.internalTransferModifier else {
            return 2
        }
        return internalTransferModifier.differenceOfDaysToDeferredTransfers
    }
}

extension InternalTransferAmountAndTypeSelectorPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: InternalTransferAmountConceptPage {
        return InternalTransferAmountConceptPage()
    }
}

private extension InternalTransferAmountAndTypeSelectorPresenter {
    func setPeriodicityModel() {
        guard let internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self) else {
            self.view?.setupPeriodicityModel(with: [.month, .quarterly, .semiannual])
            return
        }
        let model = internalTransferModifier.getPeriodicityTypes()
        self.view?.setupPeriodicityModel(with: model)
    }
    
    func setViewsVisibility() {
        guard let internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self) else {
            return
        }
        self.view?.setSelectorBussinnessDayVisibility(isEnabled: internalTransferModifier.isEnabledSelectorBusinessDateView)
    }
    
    func isEnabledValidateInternalTransfer() -> Bool {
        guard let internalTransferModifier = self.dependenciesResolver.resolve(forOptionalType: InternalTransferModifierProtocol.self) else {
            return true
        }
        return internalTransferModifier.isStandingOrderTransferSimulationEnabled
    }
    
    func continueWihtoutValidateInternalTransfer() {
        guard let view = self.view,
              let type = self.getTransferTime() else {
            return
        }
        guard let amountString = view.amount, let amountDecimal = Decimal(string: amountString.replace(".", "").replace(",", ".")) else {
            return
        }
        let amount = AmountEntity(value: amountDecimal)
        self.operativeData.internalTransfer = self.getTransferInfo(forAmount: amount)
        self.operativeData.time = type
        self.operativeData.amount = amount
        self.operativeData.concept = view.concept
        self.container?.rebuildSteps()
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
    }
    
    func getTransferInfo(forAmount amount: AmountEntity) -> InternalTransferEntity? {
        let issueDate = view?.periodicStartDate ?? Date()
        return InternalTransferEntity(amount: amount, issueDate: issueDate)
    }
    
    func getTransferTime() -> TransferTime? {
        guard let view = self.view else { return nil }
        switch view.type {
        case .now:
            return .now
        case .day:
            guard let date = view.oneDayDate else { return nil}
            return .day(date: date)
        case .periodic:
            let periodicity = view.periodicPeriodicity?.transferPeriodicity
            let emission = view.periodicEmissionDate?.transferWorkingDayIssue
            let timeEndDate: TransferTimeEndDate
            if let endDate = view.periodicEndDate,
               !view.periodicEndDateNever {
                timeEndDate = .date(endDate)
            } else {
                timeEndDate = .never
            }
            guard let startDate = view.periodicStartDate,
                  let period = periodicity,
                  let unwrapEmission = emission else {
                return nil
            }
            return .periodic(startDate: startDate,
                             endDate: timeEndDate,
                             periodicity: period,
                             workingDayIssue: unwrapEmission)
        }
    }
}
