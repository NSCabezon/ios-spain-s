import Foundation
import CoreFoundationLib

class ModifyDeferredTransferPresenter: OperativeStepPresenter<ModifyDeferredTransferViewController, Void, ModifyDeferredTransferPresenterProtocol> {
    
    private let conceptMaxLength = DomainConstant.maxLengthTransferConcept
    private var amountLabelModel: AmountInputViewModel?
    private lazy var scheduledDateItem: StockOrderValidityDateItemViewModel = {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let lowerDate = DomainConstant.scheduledTransferMinimumDate
        let dateItem = StockOrderValidityDateItemViewModel(placeholder: .empty,
                                                           date: lowerDate,
                                                           textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left),
                                                           privateComponent: dependencies)
        dateItem.lowerLimitDate = lowerDate
        dateItem.date = parameter.transferScheduled.endDate
        return dateItem
    }()
    private var conceptLabelModel: TextFieldCellViewModel?
    private var ibanModel: IBANTextFieldCellViewModel?

    // MARK: - Public methods
    
    override func loadViewData() {
        super.loadViewData()
        loadTracker()
        self.view.sections = [
            accountSection(),
            beneficiarySection(),
            ibanSection(inputIdentifier: Constants.iban.rawValue),
            amountSection(),
            conceptSection(),
            scheduledDateSection()
        ]
    }
    
    // MARK: - Private methods
    
    func loadTracker() {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        dependencies.trackerManager.trackScreen(
            screenId: TrackerPagePrivate.ModifyScheduledTransfer().page,
            extraParameters: [
                TrackerDimensions.scheduledTransferType: parameter.transferScheduled.periodicTrackerDescription
            ]
        )
    }
    
    enum Constants: String {
        case amount
        case concept
        case iban
    }
    
    private func ibanSection(inputIdentifier: String, placeholder: LocalizedStylableText? = nil) -> TableModelViewSection {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let ibanSection = TableModelViewSection()
        guard let country = parameter.country else {
            return ibanSection
        }
        let ibanTitle = TitledTableModelViewHeader()
        ibanTitle.title = stringLoader.getString("newSendOnePay_label_destinationAccounts")
        ibanSection.setHeader(modelViewHeader: ibanTitle)
        let ibanTextFieldModel = IBANTextFieldCellViewModel(inputIdentifier: inputIdentifier, placeholder: placeholder, privateComponent: dependencies, country: country)
        ibanSection.add(item: ibanTextFieldModel)
        ibanTextFieldModel.dataEntered = parameter.scheduledTransferDetail.beneficiary?.description.notWhitespaces()
        let bankingUtils = BankingUtils(dependencies: dependencies.dependenciesEngine)
        bankingUtils.setCountryCode(country.code)
        ibanTextFieldModel.bankingUtils = bankingUtils
        self.ibanModel = ibanTextFieldModel
        return ibanSection
    }
    
    private func scheduledDateSection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("newSendOnePay_label_nextIssuanceDate")
        section.setHeader(modelViewHeader: title)
        section.add(item: scheduledDateItem)
        return section
    }
    
    private func amountSection() -> TableModelViewSection {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let amountSection = TableModelViewSection()
        let amountLabelModel = AmountInputViewModel(inputIdentifier: Constants.amount.rawValue, textFormatMode: FormattedTextField.FormatMode.defaultCurrency(12, 2), dependencies: dependencies)
        let amountTitle = TitledTableModelViewHeader()
        amountTitle.title = stringLoader.getString("newSendOnePay_label_amount")
        amountSection.setHeader(modelViewHeader: amountTitle)
        amountSection.add(item: amountLabelModel)
        amountLabelModel.dataEntered = parameter.transferScheduled.amount?.getFormattedValue()
        self.amountLabelModel = amountLabelModel
        return amountSection
    }
    
    private func conceptSection() -> TableModelViewSection {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let conceptSection = TableModelViewSection()
        let conceptTitle = TitledTableModelViewHeader()
        conceptTitle.title = stringLoader.getString("newSendOnePay_label_optionalConcept")
        conceptSection.setHeader(modelViewHeader: conceptTitle)
        let placeholderString = stringLoader.getString("newSendOnePay_hint_maxCharacters", [StringPlaceholder(.number, "\(conceptMaxLength)")])
        let conceptTextFieldModel = TextFieldCellViewModel(inputIdentifier: Constants.concept.rawValue, placeholder: placeholderString, privateComponent: dependencies, maxLength: conceptMaxLength)
        conceptSection.add(item: conceptTextFieldModel)
        conceptTextFieldModel.dataEntered = parameter.transferScheduled.concept
        self.conceptLabelModel = conceptTextFieldModel
        return conceptSection
    }
    
    private func accountSection() -> TableModelViewSection {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let account = parameter.account
        let accountSection = TableModelViewSection()
        let accountItem = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShort(),
            amount: account.getAmountUI(),
            privateComponent: dependencies
        )
        let accountTitle = TitledTableModelViewHeader()
        accountTitle.title = stringLoader.getString("newSendOnePay_label_originAccount")
        accountSection.setHeader(modelViewHeader: accountTitle)
        accountSection.add(item: accountItem)
        return accountSection
    }
    
    private func beneficiarySection() -> TableModelViewSection {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        let beneficiarySection = TableModelViewSection()
        let destinationItem = ModifyScheduledTransferDestinationViewModel(
            beneficiary: parameter.scheduledTransferDetail.beneficiaryName ?? "",
            periodicity: localized(key: "confirmation_label_delayed").text,
            periodicityDetail: dependencies.timeManager.toString(date: parameter.transferScheduled.endDate, outputFormat: .dd_MMM_yyyy) ?? "",
            country: parameter.country?.name ?? "",
            currency: parameter.currency?.name ?? "",
            dependencies: dependencies
        )
        let beneficiaryTitle = TitledTableModelViewHeader()
        beneficiaryTitle.title = stringLoader.getString("newSendOnePay_label_recipients")
        beneficiarySection.setHeader(modelViewHeader: beneficiaryTitle)
        beneficiarySection.add(item: destinationItem)
        return beneficiarySection
    }
}

extension ModifyDeferredTransferPresenter: ModifyDeferredTransferPresenterProtocol {
    
    var continueButtonTitle: LocalizedStylableText {
        return localized(key: "generic_button_continue")
    }
    
    var title: String {
        return localized(key: "toolbar_title_newSendOnePay").text
    }
    
    func continueButtonDidSelected() {
        let parameter: ModifyDeferredTransferOperativeData = containerParameter()
        guard let country = parameter.country, let currency = parameter.currency, let date = scheduledDateItem.date else { return }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getModifyDeferredTransferDestinationUseCase(input: ModifyDeferredTransferDestinationUseCaseInput(
                iban: ibanModel?.dataEntered ?? "",
                amount: amountLabelModel?.dataEntered ?? "",
                concept: conceptLabelModel?.dataEntered ?? "",
                date: date,
                country: country,
                currency: currency
            )),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    parameter.modifiedData = response.modifiedData
                    strongSelf.container?.saveParameter(parameter: parameter)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error?.getErrorDesc())
                }
        })
    }
    
    func updateViewModelIbanPrefix(prefix: String) {
        guard let storedIban = ibanModel?.dataEntered else {
            return
        }
        ibanModel?.dataEntered = prefix + storedIban
    }
}

//! Deferred transfer modified by user
struct ModifiedDeferredTransfer {
    let iban: IBAN
    let amount: Amount
    let concept: String?
    let date: Date
}
