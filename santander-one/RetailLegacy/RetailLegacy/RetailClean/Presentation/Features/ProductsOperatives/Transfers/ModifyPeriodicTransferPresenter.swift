import Foundation
import CoreFoundationLib

class ModifyPeriodicTransferPresenter: OperativeStepPresenter<ModifyPeriodicTransferViewController, Void, ModifyPeriodicTransferPresenterProtocol> {
    
    private let conceptMaxLength = DomainConstant.maxLengthTransferConcept
    private var amountLabelModel: AmountInputViewModel?
    private var conceptLabelModel: TextFieldCellViewModel?
    private var ibanModel: IBANTextFieldCellViewModel?
    private var periodicalEndDateViewModel: RadioButtonAndDateViewModel?
    private lazy var periodicStartDateItem: StockOrderValidityDateItemViewModel = {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let lowerDate = DomainConstant.periodicTransferMinimumDate
        let dateItem = StockOrderValidityDateItemViewModel(placeholder: .empty,
                                                           date: lowerDate,
                                                           textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left),
                                                           privateComponent: dependencies)
        dateItem.lowerLimitDate = lowerDate
        guard let initialDate = parameter.transferScheduled.initialPeriodDate else { return dateItem }
        dateItem.date = initialDate < DomainConstant.periodicTransferMinimumDate ? DomainConstant.periodicTransferMinimumDate : parameter.transferScheduled.initialPeriodDate
        return dateItem
    }()
    private lazy var periodicity: OnePayTransferPeriodicity = {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let periodicalType = parameter.transferScheduled.periodicalType else { return .monthly }
        switch periodicalType {
        case .monthly:
            return .monthly
        case .trimestral:
            return .quarterly
        case .semiannual:
            return .biannual
        }
    }()
    private lazy var endDate: OnePayTransferTimeEndDate = {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let endDate = parameter.transferScheduled.endDate
        let isEndDateSelected = endDate != nil && endDate?.getYear() != 9999
        return isEndDateSelected ? .date(endDate ?? DomainConstant.periodicTransferMinimumDate) : .never
    }()
    private lazy var workingDayIssue: OnePayTransferWorkingDayIssue = {
        return .previousDay
    }()
    
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
            periodicitySection(),
            periodicalStartDateSection(),
            periodicalEndDateSection(),
            periodicalWorkingDayIssueSection()
        ]
    }
    
    // MARK: - Private methods
    
    func loadTracker() {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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
        case periodicity
        case workingDayIssue
    }
    
    private func ibanSection(inputIdentifier: String, placeholder: LocalizedStylableText? = nil) -> TableModelViewSection {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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
    
    private func amountSection() -> TableModelViewSection {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
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
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let beneficiarySection = TableModelViewSection()
        let endDateLocalized = stringLoader.getString("newSendOnePay_label_favoriteEndDate", [StringPlaceholder(.value, String((dependencies.timeManager.toString(date: parameter.transferScheduled.endDate, outputFormat: .dd_MMM_yyyy) ?? localized(key: "sendMoney_label_indefinite").text)))])
        let destinationItem = ModifyScheduledTransferDestinationViewModel(
            beneficiary: parameter.scheduledTransferDetail.beneficiaryName ?? "",
            periodicity: localized(key: periodicity.description).text,
            periodicityDetail: endDateLocalized.text,
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
    
    private func periodicitySection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_periodicity")
        section.setHeader(modelViewHeader: title)
        let periodicityItems: [OnePayTransferPeriodicity] = [.monthly, .quarterly, .biannual]
        let viewModel = OptionsPickerViewModel(items: periodicityItems, selected: periodicity, dependencies: dependencies) { [weak self] selected in
            self?.periodicity = selected
        }
        section.add(item: viewModel)
        return section
    }
    
    private func periodicalStartDateSection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_startDate")
        section.setHeader(modelViewHeader: title)
        section.add(item: periodicStartDateItem)
        return section
    }
    
    private func periodicalEndDateSection() -> TableModelViewSection {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_endDate")
        let endDate = parameter.transferScheduled.endDate
        let isEndDateSelected = endDate != nil && endDate?.getYear() != 9999
        let radio = RadioButtonViewModel<RadioButtonCell>(title: localized(key: "sendMoney_label_indefinite"), isSelected: !isEndDateSelected, dependencies: dependencies)
        let radioDate = RadioButtonAndDateViewModel(title: localized(key: "sendMoney_label_indicateDate"), isSelected: isEndDateSelected, dependencies: dependencies)
        radioDate.lowerLimitDate = periodicStartDateItem.lowerLimitDate?.dateByAdding(days: 1)
        radioDate.date = isEndDateSelected ? endDate : radioDate.lowerLimitDate
        section.setHeader(modelViewHeader: title)
        section.add(item: radio)
        section.add(item: radioDate)
        periodicalEndDateViewModel = radioDate
        return section
    }
    
    private func periodicalWorkingDayIssueSection() -> TableModelViewSection {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_workingDayIssue")
        section.setHeader(modelViewHeader: title)
        let viewModel = OptionsPickerViewModel(items: OnePayTransferWorkingDayIssue.allCases, selected: workingDayIssue, dependencies: dependencies) { [weak self] selected in
            self?.workingDayIssue = selected
        }
        section.add(item: viewModel)
        return section
    }
    
    private func handleRadioButtons(selected indexPath: IndexPath) {
        let section = view.sections[indexPath.section]
        section.getItems()?.enumerated().forEach {
            ($0.element as? RadioButtonSelectable)?.isSelected = ($0.offset == indexPath.row)
        }
        switch indexPath.row {
        case 0:
            endDate = .never
        case 1:
            guard let dateSelector = section.get(indexPath.row) as? RadioButtonAndDateViewModel else { return }
            endDate = .date(dateSelector.date ?? DomainConstant.periodicTransferMinimumDate)
        default:
            break
        }
        view.reloadAndSection(section: indexPath.section, scrolling: false)
    }
    
    private func handleDateChange(selected indexPath: IndexPath, date: Date) {
        let section = view.sections[indexPath.section]
        if section.get(indexPath.row) is StockOrderValidityDateItemViewModel {
            guard let periodicalEndDate = periodicalEndDateViewModel?.date, let startDate = periodicStartDateItem.date else { return }
            let endDate: Date
            if periodicalEndDate <= startDate {
                endDate = startDate.dateByAdding(days: 1)
            } else {
                endDate = periodicalEndDate
            }
            periodicalEndDateViewModel?.lowerLimitDate = startDate.dateByAdding(days: 1)
            periodicalEndDateViewModel?.date = endDate
            switch self.endDate {
            case .date:
                self.endDate = .date(endDate)
            case .never:
                break
            }
            guard let sectionIndex = view.sections.firstIndex(where: isRadioButtonAndDateSection) else { return }
            let endDateSection = view.sections[sectionIndex]
            guard let index = endDateSection.items.firstIndex(where: { $0 is RadioButtonAndDateViewModel }), let periodicalEndDateViewModel = periodicalEndDateViewModel else { return }
            view.reloadPickerConfig(periodicalEndDateViewModel, indexPath: IndexPath(row: index, section: sectionIndex))
        } else if section.get(indexPath.row) is RadioButtonAndDateViewModel {
            self.endDate = .date(date)
        }
    }
    
    private func isRadioButtonAndDateSection(_ section: TableModelViewSection) -> Bool {
        return section.items.contains(where: { $0 is RadioButtonAndDateViewModel })
    }
}

extension ModifyPeriodicTransferPresenter: ModifyPeriodicTransferPresenterProtocol {
    
    var continueButtonTitle: LocalizedStylableText {
        return localized(key: "generic_button_continue")
    }
    
    var title: String {
        return localized(key: "toolbar_title_newSendOnePay").text
    }
    
    func continueButtonDidSelected() {
        let parameter: ModifyPeriodicTransferOperativeData = containerParameter()
        guard let country = parameter.country, let currency = parameter.currency, let startDate = periodicStartDateItem.date else { return }
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ModifyPeriodicTransferDestinationUseCaseInput(
            iban: ibanModel?.dataEntered,
            amount: amountLabelModel?.dataEntered ?? "",
            concept: conceptLabelModel?.dataEntered ?? "",
            periodicity: periodicity,
            startDate: startDate,
            endDate: endDate,
            workingDayIssue: workingDayIssue,
            country: country,
            currency: currency
        )
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getModifyPeriodicTransferDestinationUseCase(input: input),
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
    
    func didSelect(indexPath: IndexPath) {
        let section = view.sections[indexPath.section]
        if section.get(indexPath.row) is RadioButtonSelectable {
            handleRadioButtons(selected: indexPath)
        }
    }
    
    func dateChanged(indexPath: IndexPath, date: Date) {
        handleDateChange(selected: indexPath, date: date)
    }
    
    func updateViewModelIbanPrefix(prefix: String) {
        guard let storedIban = ibanModel?.dataEntered else {
            return
        }
        ibanModel?.dataEntered = prefix + storedIban
    }
}

struct ModifiedPeriodicTransfer {
    let iban: IBAN
    let amount: Amount
    let concept: String?
    let periodicity: OnePayTransferPeriodicity
    let startDate: Date
    let endDate: OnePayTransferTimeEndDate
    let workingDayIssue: OnePayTransferWorkingDayIssue
}
