import Foundation

class InternalTransferInsertAmountPresenter: OperativeStepPresenter<InternalTransferInsertAmountViewController, VoidNavigator, InternalTransferInsertAmountPresenterProtocol> {
    
    // MARK: - Private attributes
    
    private var conceptTextFieldModel: TextFieldCellViewModel?
    private var amountLabelModel: AmountInputViewModel?
    private let conceptMaxLength = DomainConstant.maxLengthTransferConcept
    
    private var dateModel: OnePayTransferDestinationSegmentModel?
    private var transferTime: OnePayTransferTime = .now
    
    private lazy var scheduledDateItem: StockOrderValidityDateItemViewModel = {
        let lowerDate = DomainConstant.scheduledTransferMinimumDate
        let dateItem = StockOrderValidityDateItemViewModel(placeholder: .empty,
                                                           date: lowerDate,
                                                           textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left),
                                                           privateComponent: dependencies)
        dateItem.lowerLimitDate = lowerDate
        return dateItem
    }()
    
    private lazy var periodicStartDateItem: StockOrderValidityDateItemViewModel = {
        let lowerDate = DomainConstant.periodicTransferMinimumDate
        let dateItem = StockOrderValidityDateItemViewModel(placeholder: .empty,
                                                           date: lowerDate,
                                                           textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left),
                                                           privateComponent: dependencies)
        dateItem.lowerLimitDate = lowerDate
        return dateItem
    }()
    
    private lazy var scheduledDateSection: TableModelViewSection = {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_issuanceDate")
        section.setHeader(modelViewHeader: title)
        section.add(item: scheduledDateItem)
       return section
    }()
    
    private lazy var periodicalSections: [TableModelViewSection] = {
        return [periodicitySection, periodicalStartDateSection, periodicalEndDateSection, periodicalWorkingDayIssueSection]
    }()
    
    private lazy var periodicitySection: TableModelViewSection = {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_periodicity")
        section.setHeader(modelViewHeader: title)
        let periodicityItems: [OnePayTransferPeriodicity] = [.monthly, .quarterly, .biannual]
        let viewModel = OptionsPickerViewModel(items: periodicityItems, selected: OnePayTransferPeriodicity.monthly, dependencies: dependencies) { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.transferTime = .periodic(from: strongSelf.transferTime, periodicity: selected)
        }
        section.add(item: viewModel)
        return section
    }()
    
    private lazy var periodicalStartDateSection: TableModelViewSection = {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_startDate")
        section.setHeader(modelViewHeader: title)
        section.add(item: periodicStartDateItem)
        return section
    }()
    
    private lazy var periodicalEndDateViewModel: RadioButtonAndDateViewModel = {
        let item = RadioButtonAndDateViewModel(title: localized(key: "sendMoney_label_indicateDate"), isSelected: false, dependencies: dependencies)
        item.lowerLimitDate = periodicStartDateItem.lowerLimitDate?.dateByAdding(days: 1)
        return item
    }()
    
    private lazy var periodicalEndDateSection: TableModelViewSection = {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_endDate")
        let radio = RadioButtonViewModel<RadioButtonCell>(title: localized(key: "sendMoney_label_indefinite"), isSelected: true, dependencies: dependencies)
        section.setHeader(modelViewHeader: title)
        section.add(item: radio)
        section.add(item: periodicalEndDateViewModel)
        return section
    }()
    
    private lazy var periodicalWorkingDayIssueSection: TableModelViewSection = {
        let section = TableModelViewSection()
        let title = TitledTableModelViewHeader()
        title.title = stringLoader.getString("sendMoney_label_workingDayIssue")
        section.setHeader(modelViewHeader: title)
        let viewModel = OptionsPickerViewModel(items: OnePayTransferWorkingDayIssue.allCases, selected: OnePayTransferWorkingDayIssue.previousDay, dependencies: dependencies) { [weak self] selected in
            guard let strongSelf = self else { return }
            strongSelf.transferTime = .periodic(from: strongSelf.transferTime, workingDayIssue: selected)
        }
        section.add(item: viewModel)
        return section
    }()
    
    // MARK: - Constants
    
    fileprivate enum Constants: String {
        case amount
        case concept
    }
    
    // MARK: - Validator
    
    fileprivate struct Validator {
        let amount: String?
        let concept: String?
        let dependencies: PresentationComponent
        let transferTime: OnePayTransferTime
        
        func getValidateInputData(in container: OperativeContainerProtocol?, conceptMaxLength: Int) throws -> ValidateLocalTransferUseCaseInput {
            guard
                let amountString = amount,
                let amount = Decimal(string: amountString.replace(".", "").replace(",", "."))
                else {
                    throw Exception("generic_alert_text_errorAmount")
            }
            if let concept = concept, concept.count > conceptMaxLength {
                let conceptException = dependencies.stringLoader.getString("sendMoney_label_maxCharacters", [StringPlaceholder(StringPlaceholder.Placeholder.number, String(conceptMaxLength))])
                throw Exception(conceptException.text)
            }
            if amount == 0 {
                throw Exception("sendMoney_alert_higherValue")
            }
            guard
                let parameter: InternalTransferOperativeData = container?.provideParameter(),
                let internalTransfer = parameter.internalTransfer,
                let originAccount = internalTransfer.originAccount,
                let destinationAccount = internalTransfer.destinationAccount
                else {
                    throw Exception("generic_error_internetConnection")
            }
            return ValidateLocalTransferUseCaseInput(
                originAccount: originAccount,
                destinationAccount: destinationAccount,
                amount: Amount.createWith(value: amount),
                concept: concept ?? "",
                transferTime: transferTime,
                scheduledTransfer: nil
            )
        }
    }
    
    // MARK: - Overrided methods
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_transfer")
        // Add header of selected account
        let sectionHeader = TableModelViewSection()
        addSelectedAccountHeader(to: sectionHeader)
        // Add amount selector
        let amountSection = TableModelViewSection()
        addAmount(to: amountSection)
        // Add concept
        let conceptSection = TableModelViewSection()
        addConcept(to: conceptSection)
        // Add date selector section
        let dateSelectorSection = TableModelViewSection()
        addDateSelector(to: dateSelectorSection)
        
        view.sections = [sectionHeader, amountSection, conceptSection, dateSelectorSection]
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.InternalTransferAmountEntry().page
    }
    
    // MARK: - Private methods
    
    private func addAmount(to amountSection: TableModelViewSection) {
        let amountLabelModel = AmountInputViewModel(inputIdentifier: Constants.amount.rawValue, textFormatMode: FormattedTextField.FormatMode.defaultCurrency(12, 2), dependencies: dependencies)
        let amountTitle = TitledTableModelViewHeader()
        amountTitle.title = stringLoader.getString("newSendOnePay_label_amount")
        amountSection.setHeader(modelViewHeader: amountTitle)
        amountSection.add(item: amountLabelModel)
        self.amountLabelModel = amountLabelModel
    }
    
    private func addConcept(to conceptSection: TableModelViewSection) {
        let conceptTitle = TitledTableModelViewHeader()
        conceptTitle.title = stringLoader.getString("sendMoney_label_optionalConcept")
        conceptSection.setHeader(modelViewHeader: conceptTitle)
        let placeholderString = stringLoader.getString("newSendOnePay_hint_maxCharacters", [StringPlaceholder(.number, "\(conceptMaxLength)")])
        let conceptTextFieldModel = TextFieldCellViewModel(inputIdentifier: Constants.concept.rawValue, placeholder: placeholderString, privateComponent: dependencies, maxLength: conceptMaxLength)
        conceptSection.add(item: conceptTextFieldModel)
        self.conceptTextFieldModel = conceptTextFieldModel
    }
    
    private func addSelectedAccountHeader(to sectionHeader: TableModelViewSection) {
        let parameter: InternalTransferOperativeData = containerParameter()
        guard
            let account = parameter.internalTransfer?.originAccount,
            let selectedAccountAmount = account.getAmount(),
            let selectedAccountAlias = account.getAlias(),
            let selectedAccountIBAN = account.getIban()?.ibanShort()
            else {
                return
        }
        let headerViewModel = AccountHeaderViewModel(
            accountAlias: selectedAccountAlias,
            accountIBAN: selectedAccountIBAN,
            accountAmount: selectedAccountAmount.getAbsFormattedAmountUI()
        )
        sectionHeader.add(item: GenericHeaderViewModel(viewModel: headerViewModel, viewType: AccountOperativeHeaderView.self, dependencies: dependencies))
    }
    
    private func addDateSelector(to dateSelectorSection: TableModelViewSection) {
        let dateSelectorSectionTitle = TitledTableModelViewHeader()
        dateSelectorSectionTitle.title = stringLoader.getString("sendMoney_label_sentDate")
        dateSelectorSection.setHeader(modelViewHeader: dateSelectorSectionTitle)
        let dateSelectorModel = OnePayTransferDestinationSegmentModel(options: [stringLoader.getString("sendMoney_tab_now").text, stringLoader.getString("sendMoney_tab_chooseDay").text, stringLoader.getString("sendMoney_tab_sentPeriodic").text], dependencies: dependencies)
        dateSelectorModel.currentOption = 0
        dateSelectorModel.didSelectOption = showSection
        dateSelectorSection.add(item: dateSelectorModel)
        self.dateModel = dateSelectorModel
    }
    
    private func showSection(forOption option: Int) {
        if dateModel?.currentOption != option {
            removeScheduledSection()
            removePeriodicalSection()
            var section: Int?
            switch option {
            case 0:
                transferTime = .now
                section = view.sections.firstIndex(where: { $0 == dateModel })
            case 1:
                view.sections.append(scheduledDateSection)
                section = view.sections.firstIndex(where: { $0 == scheduledDateSection })
                transferTime = .day(date: scheduledDateItem.date ?? DomainConstant.scheduledTransferMinimumDate)
            case 2:
                view.sections.append(contentsOf: periodicalSections)
                section = view.sections.firstIndex(where: { $0 == periodicalSections.last })
                transferTime = .periodic(startDate: periodicStartDateItem.date ?? DomainConstant.periodicTransferMinimumDate,
                                         endDate: periodicalEndDateViewModel.date != nil ? .date(periodicalEndDateViewModel.date!) : .never,
                                         periodicity: .monthly, workingDayIssue: .previousDay)
            default:
                break
            }
            dateModel?.currentOption = option
            guard let sectionIndex = section else {
                view.reload()
                return
            }
            view.reloadAndBottomSection(row: view.sections[sectionIndex].rowsCount-1, section: sectionIndex)
        }
    }
    
    private func removeScheduledSection() {
        guard let index = view.sections.firstIndex(where: { $0 == scheduledDateSection }) else { return }
        view.sections.remove(at: index)
    }
    
    private func removePeriodicalSection() {
        periodicalSections.forEach { section in
            guard let index = view.sections.firstIndex(where: { section == $0 }) else { return }
            view.sections.remove(at: index)
        }
    }
    
    private func handleRadioButtons(selected indexPath: IndexPath) {
        let section = view.sections[indexPath.section]
        section.getItems()?.enumerated().forEach {
            ($0.element as? RadioButtonSelectable)?.isSelected = ($0.offset == indexPath.row)
        }
        switch indexPath.row {
        case 0:
            transferTime = .periodic(from: transferTime, endDate: .never)
        case 1:
            if periodicalEndDateViewModel.date == nil {
                guard let date = periodicStartDateItem.lowerLimitDate?.dateByAdding(days: 1) else { return }
                periodicalEndDateViewModel.date = date
            }
            guard let dateSelector = section.get(indexPath.row) as? RadioButtonAndDateViewModel else { return }
            transferTime = .periodic(from: transferTime, endDate: .date(dateSelector.date ?? DomainConstant.periodicTransferMinimumDate))
        default:
            break
        }
        view.reloadAndSection(section: indexPath.section, scrolling: false)
    }
    
    private func handleDateChange(selected indexPath: IndexPath, date: Date) {
        switch transferTime {
        case .day:
            transferTime = .day(date: date)
        case .periodic(_, .never, _, _):
            modifyDates(undefinedEndDate: true, indexPath: indexPath, date: date)
        case .periodic:
            modifyDates(undefinedEndDate: false, indexPath: indexPath, date: date)
        default:
            break
        }
    }
    
    private func isRadioButtonAndDateSection(_ section: TableModelViewSection) -> Bool {
        return section.items.contains(where: { $0 is RadioButtonAndDateViewModel })
    }
    
    private func modifyDates(undefinedEndDate: Bool, indexPath: IndexPath, date: Date) {
        let section = view.sections[indexPath.section]
        if section.get(indexPath.row) is StockOrderValidityDateItemViewModel {
            guard let periodicalEndDate = periodicalEndDateViewModel.date, let startDate = periodicStartDateItem.date, let incrementedDate = startDate.getUtcDateByAdding(days: 1) else { return }
            let endDate: Date
            if periodicalEndDate <= startDate {
                endDate = incrementedDate
            } else {
                endDate = periodicalEndDate
            }
            periodicalEndDateViewModel.lowerLimitDate = incrementedDate
            periodicalEndDateViewModel.date = endDate
            
            transferTime = .periodic(from: transferTime, startDate: startDate, endDate: undefinedEndDate ? .never : .date(endDate))
            guard let sectionIndex = view.sections.firstIndex(where: isRadioButtonAndDateSection) else { return }
            let endDateSection = view.sections[sectionIndex]
            guard let index = endDateSection.items.firstIndex(where: { $0 is RadioButtonAndDateViewModel }) else { return }
            view.reloadPickerConfig(periodicalEndDateViewModel, indexPath: IndexPath(row: index, section: sectionIndex))
        } else {
            transferTime = .periodic(from: transferTime, endDate: .date(date))
        }
    }
}

extension InternalTransferInsertAmountPresenter: InternalTransferInsertAmountPresenterProtocol {
   
    func setDate(date: Date, at indexPath: IndexPath) {
        handleDateChange(selected: indexPath, date: date)
    }
    
    func didSelect(indexPath: IndexPath) {
        let section = view.sections[indexPath.section]
        if section.get(indexPath.row) is RadioButtonSelectable {
            handleRadioButtons(selected: indexPath)
        }
    }
    
    var continueTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    func next() {
        do {
            let validator = Validator(amount: amountLabelModel?.dataEntered, concept: conceptTextFieldModel?.dataEntered, dependencies: dependencies, transferTime: transferTime)
            let validateData = try validator.getValidateInputData(in: container, conceptMaxLength: conceptMaxLength)
            showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
            UseCaseWrapper(
                with: dependencies.useCaseProvider.getValidateLocalTransferUseCase(input: validateData),
                useCaseHandler: dependencies.useCaseHandler,
                errorHandler: genericErrorHandler,
                onSuccess: { [weak self] response in
                    self?.hideAllLoadings {
                        guard let strongSelf = self else { return }
                        let parameter: InternalTransferOperativeData = strongSelf.containerParameter()
                        parameter.scheduledTransfer = response.scheduledTransfer
                        parameter.transferAccount = response.transferAccount
                        parameter.internalTransfer?.amount = validateData.amount
                        parameter.internalTransfer?.concept = validateData.concept
                        parameter.time = validateData.transferTime
                        strongSelf.container?.saveParameter(parameter: parameter)
                        strongSelf.container?.rebuildSteps()
                        strongSelf.container?.stepFinished(presenter: strongSelf)
                    }
                },
                onError: { [weak self] error in
                    self?.hideAllLoadings {
                        guard let strongSelf = self else { return }
                        strongSelf.showError(keyDesc: error?.getErrorDesc())
                    }
                }
            )
        } catch let error as Exception {
            self.showError(keyTitle: "generic_alert_title_errorData", keyDesc: error.message, phone: nil, completion: nil)
        } catch {
            self.showError(keyDesc: error.localizedDescription)
        }
    }
}
