import Foundation

class ReemittedNoSepaTransferAccountPresenter: OperativeStepPresenter<FormViewController, NoSepaNavigatorProtocol, FormPresenterProtocol> {
    private var transferType: NoSepaTransferSeletorType?
    private enum InputIdentifier: String {
        case amount
        case concept
        case bicSwift
        case bankName
        case bankAddress
        case bankPlace
        case bankCountry
    }
    private enum NoSepaTransferExpensesSeletor: CustomStringConvertible, CaseIterable {
        case shared
        case beneficiary
        case payer
        
        var description: String {
            switch self {
            case .shared:
                return "sendMoney_select_sharedExpenses"
            case .beneficiary:
                return "sendMoney_select_accountBeneficiaryExpenses"
            case .payer:
                return "sendMoney_select_accountPayerExpenses"
            }
        }
        var value: NoSepaTransferExpenses {
            switch self {
            case .shared: return .shared
            case .beneficiary: return .beneficiary
            case .payer: return .payer
            }
        }
    }
    private var transferExpenses: NoSepaTransferExpensesSeletor = .shared
    private let pdfLink = "https://infoproductos.bancosantander.es/cssa/StaticBS?blobcol=urldata&blobheadername1=content-type&blobheadername2=Content-Disposition&blobheadervalue1=application%2Fpdf&blobheadervalue2=inline%3B+filename%3Dtransferencias_exterior.pdf&blobkey=id&blobtable=MungoBlobs&blobwhere=1320599239338&cachecontrol=immediate&ssbinary=true&maxage=3600"
    private let indexSectionBank = 2
    private var parameter: ReemittedNoSepaTransferOperativeData {
         return containerParameter()
    }
    private lazy var bicSwiftSection: StackSection = {
        let sectionBankIdentifier = StackSection()
        let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bicSwift.rawValue, keyTitle: "sendMoney_label_bicSwift", placeholderKey: "onePayInternational_hint_bicSwift", initialValue: parameter.transferDetail.bicSwift)
        sectionBankIdentifier.add(items: nameTextItems)
        return sectionBankIdentifier
    }()
    private lazy var bankIdentifierSection: StackSection = {
        let sectionBankIdentifier = StackSection()
        let nameTextItems = getTextItems(inputIdentifier: InputIdentifier.bankName.rawValue, keyTitle: "sendMoney_label_nameBank", placeholderKey: nil, initialValue: parameter.transferDetail.payee?.bankName)
        sectionBankIdentifier.add(items: nameTextItems)
        let addressTextItems = getTextItems(inputIdentifier: InputIdentifier.bankAddress.rawValue, keyTitle: "sendMoney_label_optionalAddress", placeholderKey: nil, initialValue: parameter.transferDetail.payee?.bankAddress)
        sectionBankIdentifier.add(items: addressTextItems)
        let placeTextItems = getTextItems(inputIdentifier: InputIdentifier.bankPlace.rawValue, keyTitle: "sendMoney_label_optionalTown", placeholderKey: nil, initialValue: parameter.transferDetail.payee?.bankTown)
        sectionBankIdentifier.add(items: placeTextItems)
        let countryTextItems = getTextItems(inputIdentifier: InputIdentifier.bankCountry.rawValue, keyTitle: "sendMoney_label_country", placeholderKey: nil, initialValue: parameter.transferDetail.payee?.bankCountryName)
        sectionBankIdentifier.add(items: countryTextItems)
        return sectionBankIdentifier
    }()
    private enum NoSepaTransferSeletorType: CustomStringConvertible, CaseIterable {
        case identifier
        case bicSwift
        
        var description: String {
            switch self {
            case .bicSwift:
                return "sendMoney_label_bicSwift"
            case .identifier:
                return "sendMoney_hint_informationBankRecipient"
            }
        }
        var value: NoSepaTransferTypeLocal {
            switch self {
            case .bicSwift: return .bicSwift
            case .identifier: return .identifier
            }
        }
    }
    
    override var screenId: String? {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        switch parameter.operativeOrigin {
        case .emittedTransfer:
            return TrackerPagePrivate.NoSepaReemittedTransfer().amountPage
        case .favorite:
            return TrackerPagePrivate.NoSepaUsualTransfer().amountPage
        }
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = stringLoader.getString("toolbar_title_newSendOnePay")
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
        infoObtained()
    }
    
    // MARK: - Private methods
    
    private func infoObtained() {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        //TODO: Si se decide añadir el tipo segun el guardado descomentar las lineas de abajo.
//        switch parameter.transferDetail.expensesIndicator {
//        case .shared?:
//            transferExpenses = .shared
//        case .beneficiary?:
//            transferExpenses = .beneficiary
//        case .payer?:
//            transferExpenses = .payer
//        case .none:
//            transferExpenses = .shared
//        }
        switch parameter.accountType?.lowercased() {
        case "c"?:
            transferType = .bicSwift
        case "d"?:
            transferType = .identifier
        default:
            if parameter.isDestinationSepaAccount != true {
                if let bicSwift = parameter.transferDetail.bicSwift, !bicSwift.isEmpty {
                    transferType = .bicSwift
                } else {
                    transferType = .identifier
                }
            }
        }
        let sectionCommon = StackSection()
        
        //Cuenta de origen
        if let account = parameter.productSelected {
            let originAccountTitleItem = TitleLabelStackModel(title: stringLoader.getString("newSendOnePay_label_originAccount"), insets: Insets(left: 14, right: 14, top: 30, bottom: 6))
            sectionCommon.add(item: originAccountTitleItem)
            let originAccountModel = EmittedDetailAccountStackModel(account)
            sectionCommon.add(item: originAccountModel)
        }
        
        //Cuenta destino
        let destinationAccountTitleItem = TitleLabelStackModel(title: stringLoader.getString("newSendOnePay_label_recipients"), insets: Insets(left: 14, right: 14, top: 13, bottom: 6))
        sectionCommon.add(item: destinationAccountTitleItem)
        let destionationAccountItem = FavoriteTransferRecipientStackModel(
            title: LocalizedStylableText.plain(text: parameter.transferDetail.payee?.name ?? ""),
            subtitle: LocalizedStylableText.plain(text: parameter.transferDetail.payee?.paymentAccountDescription),
            country: LocalizedStylableText.plain(text: parameter.selectedCountry?.name.camelCasedString ?? ""),
            currency: LocalizedStylableText.plain(text: parameter.selectedCurrency?.name.camelCasedString ?? ""))
        sectionCommon.add(item: destionationAccountItem)
        
        //Importe
        let amountModelTitleItem = TitleLabelStackModel(title: stringLoader.getString("sendMoney_label_amount"), insets: Insets(left: 14, right: 14, top: 13, bottom: 0))
        sectionCommon.add(item: amountModelTitleItem)
        let amountFormat: FormattedTextField.FormatMode
        if let currencyName = parameter.selectedCurrency?.getSymbol {
            amountFormat = FormattedTextField.FormatMode.currency(12, 2, currencyName)
        } else {
            amountFormat = FormattedTextField.FormatMode.defaultCurrency(12, 2)
        }
        let amountModel = AmountInputStackModel(inputIdentifier: InputIdentifier.amount.rawValue, titleText: stringLoader.getString(""), textFormatMode: amountFormat, insets: Insets(left: 10, right: 10, top: 0, bottom: 0))
        sectionCommon.add(item: amountModel)
        
        //Concepto
        let conceptTitleItem = TitleLabelStackModel(title: stringLoader.getString("sendMoney_label_optionalConcept"), insets: Insets(left: 14, right: 14, top: 13, bottom: 6))
        sectionCommon.add(item: conceptTitleItem)
        let conceptMaxLength = DomainConstant.maxLengthTransferConcept
        let placeholderString = stringLoader.getString("newSendOnePay_hint_maxCharacters", [StringPlaceholder(.number, "\(conceptMaxLength)")])
        let conceptModel = TextFieldStackModel(inputIdentifier: InputIdentifier.concept.rawValue, placeholder: placeholderString, insets: Insets(left: 10, right: 10, top: 0, bottom: 3), maxLength: conceptMaxLength)
        sectionCommon.add(item: conceptModel)
        
        //Gastos
        let sectionExpensesTitle = TitleLabelInfoStackModel(title: dependencies.stringLoader.getString("sendMoney_label_expensesPay"), tooltipText: dependencies.stringLoader.getString("tooltip_label_payExpenses"), tooltipTitle: dependencies.stringLoader.getString("tooltip_title_payExpenses"), actionDelegate: self, insets: Insets(left: 14, right: 14, top: 13, bottom: 6))
        sectionCommon.add(item: sectionExpensesTitle)
        let selectorExpensesModel = OptionsPickerStackModel(items: NoSepaTransferExpensesSeletor.allCases, selected: transferExpenses, dependencies: dependencies, insets: Insets(left: 10, right: 10, top: 0, bottom: 0)) { [weak self] selected in
            self?.transferExpenses = selected
        }
        sectionCommon.add(item: selectorExpensesModel)
        let expensePdfModel = LinkPdfStackModel(title: dependencies.stringLoader.getString("sendMoney_link_seeRates"), linkTouch: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let requestComponents = OrdinaryRequestComponents(url: strongSelf.pdfLink, params: [:], method: .get, fields: nil, cookies: [:])
            let input = GetPdfUseCaseInput(requestComponents: requestComponents, cache: false)
            strongSelf.showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: strongSelf.view, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                UseCaseWrapper(with: strongSelf.useCaseProvider.getPdfUseCase(input: input), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] responsePdf in
                    self?.hideLoading(completion: { [weak self] in
                        self?.navigator.goToPdfViewer(pdfData: responsePdf.pdfDocument)
                    })
                    }, onError: { [weak self] _ in
                        self?.hideLoading()
                })
            })
        })
        sectionCommon.add(item: expensePdfModel)
        var sections = [sectionCommon]
        let banckSection = getBankSection()
        sections.append(contentsOf: banckSection)
        view.dataSource.reloadSections(sections: sections)
    }
    
    private func getBankSection() -> [StackSection] {
        guard let transferType = transferType else {
            return []
        }
        let sectionBankSelector = StackSection()
        let bankSelectorTitleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString("sendMoney_label_bankIdentifier"))
        sectionBankSelector.add(item: bankSelectorTitleHeader)
        let bankSelectorModel = OptionsPickerStackModel(items: NoSepaTransferSeletorType.allCases, selected: transferType, dependencies: dependencies) { [weak self] selected in
            self?.transferType = selected
            self?.updateBankSections()
        }
        sectionBankSelector.add(item: bankSelectorModel)
        let sectionBankIdentifier = getBankIdentifierSection()
        return [sectionBankSelector, sectionBankIdentifier]
    }
    
    private func getBankIdentifierSection() -> StackSection {
        switch transferType {
        case .bicSwift?:
            return bicSwiftSection
        case .identifier?:
            return bankIdentifierSection
        case .none:
            return StackSection()
        }
    }
    
    private func dateEnteredForIdentifier(_ identifier: InputIdentifier) -> String? {
        return view.dataSource.findData(identifier: identifier.rawValue)
    }
    
    private func updateBankSections() {
        view.dataSource.removeSection(index: indexSectionBank)
        let sectionBankIdentifier = getBankIdentifierSection()
        view.dataSource.insertSection(section: sectionBankIdentifier, index: indexSectionBank)
    }
    
    private func getTextItems(inputIdentifier: String, keyTitle: String, placeholderKey: String?, initialValue: String?) -> [StackItemProtocol] {
        var items: [StackItemProtocol] = []
        let titleHeader = TitleLabelStackModel(title: dependencies.stringLoader.getString(keyTitle), insets: Insets(left: 14, right: 14, top: 13, bottom: 6))
        items.append(titleHeader)
        let placeholder: LocalizedStylableText?
        if let placeholderKey = placeholderKey {
            placeholder = dependencies.stringLoader.getString(placeholderKey)
        } else {
            placeholder = nil
        }
        let textFieldModel = TextFieldStackModel(inputIdentifier: inputIdentifier, placeholder: placeholder, insets: Insets(left: 10, right: 10, top: 0, bottom: 3), maxLength: 50)
        if let value = initialValue {
            textFieldModel.setCurrentValue(value)
        }
        items.append(textFieldModel)
        return items
    }
}

// MARK: - FormPresenterProtocol

extension ReemittedNoSepaTransferAccountPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        let parameter: ReemittedNoSepaTransferOperativeData = containerParameter()
        guard let originAccount = parameter.productSelected else { return }
        let date: Date = Date()
        let concept = dateEnteredForIdentifier(.concept)
        let input = DestinationNoSepaReemittedTransferUseCaseInput(
            expenses: transferExpenses.value,
            type: transferType?.value,
            amount: dateEnteredForIdentifier(.amount),
            bankName: transferType == .identifier ? dateEnteredForIdentifier(.bankName) : nil,
            bankAddress: transferType == .identifier ? dateEnteredForIdentifier(.bankAddress) : nil,
            bankCity: transferType == .identifier ? dateEnteredForIdentifier(.bankPlace) : nil,
            bankCountry: transferType == .identifier ? dateEnteredForIdentifier(.bankCountry) : nil,
            bankBicSwift: transferType == .bicSwift ? dateEnteredForIdentifier(.bicSwift) : nil,
            originAccount: originAccount,
            transferDetail: parameter.transferDetail,
            concept: concept
        )
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        UseCaseWrapper(
            with: useCaseProvider.getDestinationNoSepaReemittedTransferUseCase(input: input),
            useCaseHandler: useCaseHandler,
            errorHandler: genericErrorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    guard let strongSelf = self else { return }
                    parameter.transferExpenses = strongSelf.transferExpenses.value
                    parameter.swiftValidation = result.swiftValidation
                    parameter.transferType = result.transferType
                    parameter.noSepaTransferValidation = result.noSepaTransferValidation
                    parameter.amount = result.amount
                    parameter.beneficiaryAccount = result.beneficiaryAccount
                    parameter.concept = concept
                    parameter.date = date
                    strongSelf.container?.saveParameter(parameter: parameter)
                    strongSelf.container?.stepFinished(presenter: strongSelf)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    switch error?.type {
                    case .service?, .none:
                        self?.showError(keyTitle: nil, keyDesc: error?.getErrorDesc())
                    case .amount?:
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "sendMoney_alert_amountTransfer")
                    case .zero?:
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "sendMoney_alert_higherValue")
                    case .nameBankError?:
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_nameBank")
                    case .bicSwiftError?:
                        self?.showError(keyTitle: "generic_alert_title_errorData", keyDesc: "onePay_alert_bicSwift")
                    }
                }
            }
        )
    }
}

// MARK: - TooltipTextFieldActionDelegate

extension ReemittedNoSepaTransferAccountPresenter: TooltipTextFieldActionDelegate {
    func auxiliaryButtonAction(completion: (TooltipTextFieldAuxiliaryAction) -> Void) {
        completion(.toolTip(delegate: view))
    }
}
