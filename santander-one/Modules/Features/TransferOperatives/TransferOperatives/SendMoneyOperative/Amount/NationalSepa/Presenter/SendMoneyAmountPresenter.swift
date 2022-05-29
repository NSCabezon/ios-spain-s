//
//  SendMoneyAmountPresenter.swift
//  TransferOperatives
//
//  Created by Cristobal Ramos Laina on 27/9/21.
//

import Operative
import CoreFoundationLib
import CoreDomain
import SANLegacyLibrary

protocol SendMoneyAmountPresenterProtocol: OperativeStepPresenterProtocol, SendMoneyCurrencyHelperPresenterProtocol {
    var view: SendMoneyAmountView? { get set }
    func viewDidLoad()
    func viewDidAppear()
    func didSelectAccount(_ cardViewModel: OneAccountSelectionCardItem)
    func didSelectBack()
    func didSelectClose()
    func didSelectContinue()
    func getSubtitleInfo() -> String
    func getStepOfSteps() -> [Int]
    func didSelectFrequency(_ type: SendMoneyPeriodicityTypeViewModel)
    func didSelectBusinessDay(_ type: SendMoneyEmissionTypeViewModel)
    func didSelectStartDate(_ date: Date)
    func didSelectEndDate(_ date: Date)
    func didSelectDeadlineCheckbox(_ isDeadline: Bool)
    func didSelectIssueDate(_ date: Date)
    func changeOriginAccount()
    func changeDestinationAccount()
    func didSelecteOneFilterSegment(_ type: SendMoneyDateTypeViewModel)
    func getSendMoneyPeriodicity(_ index: Int) -> SendMoneyPeriodicityTypeViewModel
    func saveAmountAndDescription(amount: String, description: String?)
}

final class SendMoneyAmountPresenter {
    var number: Int = 0
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    weak var view: SendMoneyAmountView?
    let dependenciesResolver: DependenciesResolver
    var shouldShowProgressBar: Bool = true
    private var transferTime: SendMoneyDateTypeFilledViewModel = .now
    private var isEnabledTextFields = false
    private var isEnabledFloattingButton = false
    private var selectedIssueDate: Date?
    lazy var operativeData: SendMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    private var destinationIban: IBANRepresentable? {
        return self.operativeData.destinationIBANRepresentable
    }
    
    var sendMoneyUseCaseProvider: SendMoneyUseCaseProviderProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SendMoneyAmountPresenter: SendMoneyAmountPresenterProtocol {
    func viewDidAppear() {
        self.setFloattingButton()
    }
    
    func saveAmountAndDescription(amount: String, description: String?) {
        if !amount.isEmpty {
            guard let currency = self.operativeData.currency else { return }
            let currencyRepresentable = CurrencyRepresented(currencyName: currency.code, currencyCode: currency.code)
            self.operativeData.amount = AmountRepresented(value: amount.notWhitespaces().stringToDecimal ?? 0, currencyRepresentable: currencyRepresentable)
        } else {
            self.operativeData.amount = nil
        }
        self.operativeData.description = description
        self.didUpdateTextFields(isAmountTextFieldEmpty: amount.isEmpty, isDescriptionTextFieldEmpty: description?.isEmpty ?? true)
    }
    
    func getSendMoneyPeriodicity(_ index: Int) -> SendMoneyPeriodicityTypeViewModel {
        self.operativeData.indexPeriodicity = index
        return self.sendMoneyModifier?.getSendMoneyPeriodicityType(index) ?? .month
    }
    
    func viewDidLoad() {
        self.initialOperativeDataLoad()
        self.setAccountSelectorView()
        self.loadCurrenciesSelectionItems()
        self.view?.addSendMoneyAmountAndDescriptionView(amount: self.operativeData.amount?.value,
                                                        description: self.operativeData.description,
                                                        isCurrencyEditable: self.isCurrencyEditable,
                                                        currencyCode: self.operativeData.currency?.code
        )
        self.setSelectDateOneViewModels()
        self.trackerManager.trackScreen(screenId: self.trackerPage.page, extraParameters: self.operativeData.type == .national ? ["transfer_country" : self.operativeData.type.trackerName] : [:])
    }
    
    func initialOperativeDataLoad() {
        self.operativeData.destinationAccountCurrency = self.operativeData.currency
        self.container?.save(self.operativeData)
    }
    
    func didSelectAccount(_ cardViewModel: OneAccountSelectionCardItem) {
        self.operativeData.selectedAccount = cardViewModel.account
        self.container?.stepFinished(presenter: self)
    }
    
    func didSelectClose() {
        self.container?.close()
    }
    
    func didSelectBack() {
        self.container?.back()
    }
    
    func changeOriginAccount() {
        self.container?.back(
            to: SendMoneyAccountSelectorPresenter.self,
            creatingAt: 0,
            step: SendMoneyAccountSelectorStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func changeDestinationAccount() {
        self.container?.back(
            to: SendMoneyDestinationAccountPresenter.self,
            creatingAt: 0,
            step: SendMoneyDestinationStep(dependenciesResolver: self.dependenciesResolver))
    }
    
    func didSelectContinue() {
        self.setTransferTime()
        self.goToNextStep()
    }
    
    func getSubtitleInfo() -> String {
        self.container?.getSubtitleInfo(presenter: self) ?? ""
    }
    
    func getStepOfSteps() -> [Int] {
        self.container?.getStepOfSteps(presenter: self) ?? []
    }
    
    func didSelectFrequency(_ type: SendMoneyPeriodicityTypeViewModel) {
        self.operativeData.periodicalTypeTransfer = type
    }
    
    func didSelectBusinessDay(_ type: SendMoneyEmissionTypeViewModel) {
        self.operativeData.transferWorkingDayIssue = type
    }
    
    func didSelectStartDate(_ date: Date) {
        self.operativeData.startDate = date
    }
    
    func didSelectEndDate(_ date: Date) {
        self.operativeData.endDate = date
        self.setFloattingButton()
    }
    
    func didSelectDeadlineCheckbox(_ isDeadline: Bool) {
        self.operativeData.isSelectDeadlineCheckbox = isDeadline
        self.setFloattingButton()
    }
    
    func didSelectIssueDate(_ date: Date) {
        self.operativeData.issueDate = date
        self.selectedIssueDate = date
    }
    
    func didSelecteOneFilterSegment(_ type: SendMoneyDateTypeViewModel) {
        self.operativeData.transferDateType = type
        if type == .day && self.selectedIssueDate == nil {
            let date = Date().getDateByAdding(days: 2)
            self.selectedIssueDate = date
            self.operativeData.issueDate = date
        }
        self.setFloattingButton()
    }
}

private extension SendMoneyAmountPresenter {
    
    var sendMoneyModifier: SendMoneyModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)
    }
    
    var isCurrencyEditable: Bool {
        let isCurrencyEditable = self.sendMoneyModifier?.isCurrencyEditable(self.operativeData)
        return isCurrencyEditable ?? false
    }
    
    func didUpdateTextFields(isAmountTextFieldEmpty: Bool, isDescriptionTextFieldEmpty: Bool) {
        self.isEnabledTextFields = !self.areEmptyRequiredTextFields(isAmountTextFieldEmpty: isAmountTextFieldEmpty, isDescriptionTextFieldEmpty: isDescriptionTextFieldEmpty)
        self.setFloattingButton()
    }
    
    func setAccountSelectorView() {
        guard let selectedAccount = self.operativeData.selectedAccount,
              let destinationIban = self.destinationIban
        else { return }
        var originImage: String?
        if let mainAcount = self.operativeData.mainAccount, mainAcount.equalsTo(other: selectedAccount) {
            originImage = "icnHeartTint"
        }
        let amountType = self.sendMoneyModifier?.amountToShow ?? .currentBalance
        let viewModel = OneAccountsSelectedCardViewModel(
            statusCard: .expanded(
                OneAccountsSelectedCardExpandedViewModel(
                    destinationIban: destinationIban,
                    destinationAlias: self.operativeData.destinationAlias ?? self.operativeData.destinationName,
                    destinationCountry: self.operativeData.destinationCountryName ?? ""
                )
            ),
            originAccount: selectedAccount,
            originImage: originImage,
            amountToShow: amountType
        )
        self.view?.addAccountSelector(viewModel)
    }
    
    func setSelectDateOneViewModels() {
        guard let selectionDateOneFilterViewModel = self.sendMoneyModifier?.selectionDateOneFilterViewModel,
              let freqOneInputSelectViewModel = self.sendMoneyModifier?.freqOneInputSelectViewModel,
              let selectionIssueDateViewModel = self.sendMoneyModifier?.selectionIssueDateViewModel
        else { return }
        let bussinessOneInputSelectViewModel = self.sendMoneyModifier?.bussinessOneInputSelectViewModel
        let frequencyDeadlineOneSelectDateViewModel = self.getFrequencyViewModel()
        freqOneInputSelectViewModel.setSelectedInput(self.operativeData.indexPeriodicity ?? 0)
        let settedSelectionDateOneFilterViewModel = self.setSelectionDateOneFilterViewModel(selectionDateOneFilterViewModel)
        let issueDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver,
                                                       status: .activated,
                                                       firstDate: self.operativeData.issueDate,
                                                       minDate:                                                selectionIssueDateViewModel.minDate,
                                                       maxDate: selectionIssueDateViewModel.maxDate)
        self.selectedIssueDate = self.operativeData.transferDateType == .day ? self.operativeData.issueDate : nil
        let viewModel = SelectDateOneContainerViewModel(selectionDateOneFilterViewModel: settedSelectionDateOneFilterViewModel,
                                                        oneInputSelectFrequencyViewModel: freqOneInputSelectViewModel,
                                                        frequencyDeadlineOneSelectDateViewModel: frequencyDeadlineOneSelectDateViewModel,
                                                        oneInputSelectViewModel: bussinessOneInputSelectViewModel,
                                                        oneInputDateViewModel: issueDateViewModel,
                                                        dependenciesResolver: self.dependenciesResolver)
        self.view?.addSelectDateOneContainerView(viewModel, isSelectDeadlineCheckbox: self.operativeData.isSelectDeadlineCheckbox, endDate: self.operativeData.endDate)
    }
    
    func setSelectionDateOneFilterViewModel(_ selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel) -> SelectionDateOneFilterViewModel {
        var viewModel = selectionDateOneFilterViewModel
        var index = 0
        if let tranferType = self.operativeData.transferDateType {
            switch tranferType {
            case .day: index = 1
            case .periodic: index = 2
            default: index = 0
            }
        } else {
            index = 0
        }
        viewModel.setSelectedIndex(index)
        return viewModel
    }
    
    func getFrequencyViewModel() -> FrequencyDeadlineOneSelectDateViewModel {
        let startDate = Date().getDateByAdding(days: 2)
        let endDate = Date().getDateByAdding(days: 3)
        let startDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver,
                                                       status: .activated,
                                                       firstDate: self.operativeData.startDate ?? startDate, minDate: startDate)
        let endDateViewModel = OneInputDateViewModel(dependenciesResolver: self.dependenciesResolver,
                                                     status: .disabled,
                                                     firstDate: self.operativeData.endDate,
                                                     minDate: endDate)
        var status: OneStatus = .activated
        if self.operativeData.isSelectDeadlineCheckbox == false {
            status = .inactive
        }
        let checkboxViewModel = OneCheckboxViewModel(status: status,
                                                     titleKey: "sendMoney_label_indefinite",
                                                     accessibilityActivatedLabel: localized("voiceover_noDeadlineOptionSelected"),
                                                     accessibilityNoActivatedLabel: localized("voiceover_noDeadlineOptionUnselected"))
        return FrequencyDeadlineOneSelectDateViewModel(startDateViewModel: startDateViewModel, endDateViewModel: endDateViewModel, deadlineCheckBoxViewModel: checkboxViewModel)
    }
    
    func goToNextStep() {
        let useCase = self.sendMoneyUseCaseProvider.getAmountUseCase()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: self.operativeData)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.container?.save(response)
                self.view?.hideLoading()
                if let output = response.specialPricesOutput,
                   output.shouldShowSpecialPrices {
                    self.container?.stepFinished(presenter: self)
                } else {
                    self.container?.go(to: SendMoneyConfirmationPresenter.self)
                }
            }
            .onError { [weak self] error in
                guard let self = self else { return }
                self.view?.hideLoading()
                self.container?.showGenericError()
            }
    }
    
    func setTransferTime() {
        switch self.operativeData.transferDateType {
        case .now, .none:
            self.transferTime = .now
            self.operativeData.transferFullDateType = .now
        case .day:
            self.transferTime = .day(date: self.operativeData.issueDate)
            self.operativeData.transferFullDateType = .day(date: self.operativeData.issueDate)
        case .periodic:
            self.transferTime = self.setPeriodicType()
            self.operativeData.transferFullDateType = self.setPeriodicType()
        }
    }
    
    func setPeriodicType() -> SendMoneyDateTypeFilledViewModel {
        var timeEndDate: PeriodicEndDateTypeFilledViewModel = .never
        let startDate = self.operativeData.startDate ?? Date().getDateByAdding(days: 2)
        let endDate = self.operativeData.endDate ?? Date().getDateByAdding(days: 3)
        self.operativeData.startDate = startDate
        if self.operativeData.isSelectDeadlineCheckbox == false {
            timeEndDate = .date(endDate)
            self.operativeData.endDate = endDate
        }
        return .periodic(start: startDate,
                         end: timeEndDate,
                         periodicity: self.operativeData.periodicalTypeTransfer ?? self.getPeriodicity(),
                         emission: self.operativeData.transferWorkingDayIssue ?? .next)
    }
    
    func isEnabledEndDate() -> Bool {
        guard self.operativeData.transferDateType == .periodic && self.operativeData.isSelectDeadlineCheckbox == false && self.operativeData.endDate == nil else {
            return true
        }
        return false
    }
    
    func areEmptyRequiredTextFields(isAmountTextFieldEmpty: Bool, isDescriptionTextFieldEmpty: Bool) -> Bool {
        if isAmountTextFieldEmpty { return true }
        if self.sendMoneyModifier?.isDescriptionRequired == true && isDescriptionTextFieldEmpty { return true }
        return false
    }
    
    func getPeriodicity() -> SendMoneyPeriodicityTypeViewModel {
        let periodicity = self.sendMoneyModifier?.getSendMoneyPeriodicityType(0) ?? .month
        self.operativeData.periodicalTypeTransfer = periodicity
        return periodicity
    }
    
    func setFloattingButton() {
        self.isEnabledFloattingButton = self.isEnabledTextFields && self.isEnabledEndDate()
        self.view?.isEnabledFloattingButton(self.isEnabledFloattingButton)
    }
}

// MARK: SendMoneyCurrencyHelperPresenterProtocol
extension SendMoneyAmountPresenter {
    var viewCurrencyHelper: SendMoneyCurrencyHelperViewProtocol? {
        return self.view
    }
}

extension SendMoneyAmountPresenter: AutomaticScreenTrackable {
    var trackerPage: SendMoneyAmountAndDatePage {
        SendMoneyAmountAndDatePage(national: self.operativeData.type == .national, type: self.operativeData.type.trackerName)
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
