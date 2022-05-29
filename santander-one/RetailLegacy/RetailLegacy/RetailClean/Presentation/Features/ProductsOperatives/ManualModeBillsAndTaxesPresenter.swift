import Foundation
import CoreFoundationLib

class ManualModeBillsAndTaxesPresenter: OperativeStepPresenter<ManualModeBillsAndTaxesViewController, VoidNavigator, ManualModeBillsAndTaxesPresenterProtocol> {
    // MARK: - Overrided methods
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard (parameter.paymentBillTaxes) == nil else {
            onSuccess(false)
            return
        }
        onSuccess(true)
    }
    
    override var screenId: String? {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return nil }
        switch type {
        case .bills: return TrackerPagePrivate.BillAndTaxesPayBillManualData().page
        case .taxes: return TrackerPagePrivate.BillAndTaxesPayTaxManualData().page
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        let parameter: BillAndTaxesOperativeData = containerParameter()
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            view.styledTitle = stringLoader.getString("toolbar_title_receipts")
            view.localizedSubTitleKey = "toolbar_title_payReceipts"
        case .taxes:
            view.styledTitle = stringLoader.getString("toolbar_title_taxes")
            view.localizedSubTitleKey = "toolbar_title_taxPayment" 
        }
        prepareView()
    }
    
    private func prepareView() {
        let parameter: BillAndTaxesOperativeData = containerParameter()
        let sectionHeader = TableModelViewSection()
        addSelectedAccountHeader(to: sectionHeader, parameter: parameter)
        
        let sectionContent = TableModelViewSection()
        addCodeEntityToolTipTextFieldCell(to: sectionContent, parameter: parameter)
        addReferenceToolTipTextFieldCell(to: sectionContent, parameter: parameter)
        addIdentifierToolTipTextFieldCell(to: sectionContent, parameter: parameter)
        addAmountInputViewModel(to: sectionContent, parameter: parameter)
        
        view.sections = [sectionHeader, sectionContent]
    }
    
    private func addSelectedAccountHeader(to sectionHeader: TableModelViewSection, parameter: BillAndTaxesOperativeData) {
        guard
            let account = parameter.productSelected,
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
    
    private func createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: String, keyTitleText: String, maximumValue: Int, keyTooltipTitle: String, keyTooltipText: String) -> TooltipInTitleWithTextFieldViewModel {
        return TooltipInTitleWithTextFieldViewModel(inputIdentifier: modelIdentifier,
                                             titleText: stringLoader.getString(keyTitleText),
                                             textFormatMode: .numericInteger(maximumValue),
                                             style: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left),
                                             delegate: view,
                                             tooltipTitle: stringLoader.getString(keyTooltipTitle),
                                             tooltipText: stringLoader.getString(keyTooltipText),
                                             dependencies: dependencies)
    }
    
    private func addCodeEntityToolTipTextFieldCell(to sectionContent: TableModelViewSection, parameter: BillAndTaxesOperativeData) {
        let codeIssuingEntity: TooltipInTitleWithTextFieldViewModel
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            codeIssuingEntity = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "codeEntity", keyTitleText: "receiptsAndTaxes_label_codeIssuingEntity", maximumValue: 11, keyTooltipTitle: "tooltip_title_codeIssuingEntity", keyTooltipText: "tooltip_label_receiptsNum11")
        case .taxes:
            codeIssuingEntity = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "codeEntity", keyTitleText: "receiptsAndTaxes_label_codeIssuingEntity", maximumValue: 6, keyTooltipTitle: "tooltip_title_codeIssuingEntity", keyTooltipText: "tooltip_label_taxesNum6")
        }
        codeIssuingEntity.accessibilityIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.codeIssuingEntity
        sectionContent.items.append(codeIssuingEntity)
    }
    
    private func addReferenceToolTipTextFieldCell(to sectionContent: TableModelViewSection, parameter: BillAndTaxesOperativeData) {
        let reference: TooltipInTitleWithTextFieldViewModel
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            reference = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "reference", keyTitleText: "receiptsAndTaxes_label_reference", maximumValue: 13, keyTooltipTitle: "tooltip_title_reference", keyTooltipText: "tooltip_label_receiptsNum13")
        case .taxes:
            reference = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "reference", keyTitleText: "receiptsAndTaxes_label_reference", maximumValue: 12, keyTooltipTitle: "tooltip_title_reference", keyTooltipText: "tooltip_label_taxesNum12")
        }
        reference.accessibilityIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.reference
        sectionContent.items.append(reference)
    }
    
    private func addIdentifierToolTipTextFieldCell(to sectionContent: TableModelViewSection, parameter: BillAndTaxesOperativeData) {
        let identification: TooltipInTitleWithTextFieldViewModel
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            identification = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "identification", keyTitleText: "receiptsAndTaxes_label_identification", maximumValue: 6, keyTooltipTitle: "tooltip_title_identification", keyTooltipText: "tooltip_label_receiptsNum6")
        case .taxes:
            identification = createTooltipInTitleWithTextFieldCellViewModel(modelIdentifier: "identification", keyTitleText: "receiptsAndTaxes_label_identification", maximumValue: 10, keyTooltipTitle: "tooltip_title_identification", keyTooltipText: "tooltip_label_taxesNum7To10")
        }
        identification.accessibilityIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.identification
        sectionContent.items.append(identification)
    }
    
    private func addAmountInputViewModel(to sectionContent: TableModelViewSection, parameter: BillAndTaxesOperativeData) {
        let amount: AmountInputViewModel
        let titleIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.amount + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewTitleLabel
        let textInputIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.amount + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewFormattedTextFieldLabel
        let textInputRightImageIdentifier = AccesibilityBills.BillEmittersPaymentInputModeView.amount + AccesibilityLegacy.TooltipInTitleWithTextFieldView.viewFormattedTextFieldImage
        guard let type = parameter.typeOperative else { return }
        switch type {
        case .bills:
            amount = AmountInputViewModel(inputIdentifier: "amount", titleText: stringLoader.getString("receiptsAndTaxes_label_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(8, 2), dependencies: dependencies, titleIdentifier: titleIdentifier, textInputIdentifier: textInputIdentifier, textInputRightImageIdentifier: textInputRightImageIdentifier)
        case .taxes:
            amount = AmountInputViewModel(inputIdentifier: "amount", titleText: stringLoader.getString("receiptsAndTaxes_label_amount"), textFormatMode: FormattedTextField.FormatMode.defaultCurrency(6, 2), dependencies: dependencies, titleIdentifier: titleIdentifier, textInputIdentifier: textInputIdentifier, textInputRightImageIdentifier: textInputRightImageIdentifier)
        }
        sectionContent.items.append(amount)
    }
    
    private func viewModelForIdentifier(identifier: String) -> String? {
        let sections = view.itemsSectionContent().compactMap({$0 as? InputIdentificable}).filter({$0?.inputIdentifier == identifier}).compactMap({$0})
        return sections.first?.dataEntered
    }
}

extension ManualModeBillsAndTaxesPresenter: ManualModeBillsAndTaxesPresenterProtocol {
    func onContinueButtonClicked() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        guard let selectedAccount = operativeData.productSelected, let type = operativeData.typeOperative else { return }
        
        let input = PreValidateManualBillsAndTaxesUseCaseInput(type: type,
                                                               entityCode: viewModelForIdentifier(identifier: "codeEntity"),
                                                               reference: viewModelForIdentifier(identifier: "reference"),
                                                               id: viewModelForIdentifier(identifier: "identification"),
                                                               amount: viewModelForIdentifier(identifier: "amount"))
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(with: dependencies.useCaseProvider.getPreValidateManualBillsAndTaxesUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (resultManual) in
                guard let strongSelf = self, let codeScan = resultManual.code else { return }
                
                let input = PreValidateScannerBillsAndTaxesUseCaseInput(code: codeScan, type: type, originAccount: selectedAccount)
                UseCaseWrapper(with: strongSelf.dependencies.useCaseProvider.getPreValidateScannerBillsAndTaxesUseCase(input: input), useCaseHandler: strongSelf.dependencies.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (resultScanner) in
                    self?.hideAllLoadings {
                        guard let strongSelf = self else { return }
                        let parameter: BillAndTaxesOperativeData = strongSelf.containerParameter()
                        parameter.paymentBillTaxes = resultScanner.paymentBillTaxes
                        strongSelf.container?.saveParameter(parameter: parameter)
                        strongSelf.container?.stepFinished(presenter: strongSelf)
                    }
                    }, onError: { [weak self] (error) in
                        guard let strongSelf = self else { return }
                        strongSelf.hideLoading(completion: {
                            switch error?.validationError {
                            case .other?:
                                strongSelf.showError(keyDesc: error?.getErrorDesc())
                            case .notValidFormat?:
                                strongSelf.showError(keyDesc: "login_popupError_validateData")
                            case .service?:
                                strongSelf.manageRepositoryError(error?.getErrorDesc())
                            case .none:
                                strongSelf.showError(keyDesc: error?.getErrorDesc())
                            case .invalidTypeBills?:
                                strongSelf.showError(keyDesc: "login_popupError_validateData")
                            case .invalidTypeTaxes?:
                                strongSelf.showError(keyDesc: "login_popupError_validateData")
                            }
                        })
                })
            }, onError: { [weak self] (error) in
                guard let strongSelf = self else { return }
                strongSelf.hideLoading(completion: {
                    switch error?.manualError {
                    case .some(.amountEqualZero):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_alert_text_errorData_amount")
                    case .some(.amountNotValid):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_alert_text_errorData_numberAmount")
                    case .some(.notNumeric), .some(.empty), .some(.other):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_alert_text_errorCompleteFields")
                    case .none:
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "generic_alert_text_errorCompleteFields")
                    case .some(.lessThanMaxEntityCodeBills):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_receiptsNum11")
                    case .some(.lessThanMaxReferenceBills):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_receiptsNum13")
                    case .some(.lessThanMaxIdBills):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_receiptsNum6")
                    case .some(.lessThanMaxEntityCodeTaxes):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_taxesNum6")
                    case .some(.lessThanMaxReferenceTaxes):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_taxesNum12")
                    case .some(.lessThanMaxIdTaxes):
                        strongSelf.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "receiptsAndTaxes_alert_taxesNum7To10")
                    }
                })
        })
    }
    
    var buttonTitle: LocalizedStylableText {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    func didTapClose() {
        container?.cancelTouched(completion: nil)
    }
    
    func didTapFaqs() {
        let operativeData: BillAndTaxesOperativeData = containerParameter()
        let faqs = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        self.dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.BillAndTaxesFaq().page, extraParameters: [:])
        self.view.showFaqs(faqs)
    }
    
    func didTapBack() {
        container?.operativeContainerNavigator.back()
    }
    
    func manageRepositoryError(_ errorDescription: String?) {
        if (errorDescription ?? "").hasPrefix("0000") {
            showError(keyDesc: "operative_error_JO_0000")
        } else {
            showError(keyDesc: errorDescription)
        }
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question":question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: .billsFaqsAnalytics, object: nil, userInfo: ["parameters": dic])
    }
}
