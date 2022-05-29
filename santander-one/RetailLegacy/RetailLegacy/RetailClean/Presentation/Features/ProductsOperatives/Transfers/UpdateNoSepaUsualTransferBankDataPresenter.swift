class UpdateNoSepaUsualTransferBankDataPresenter: OperativeStepPresenter<FormViewController, VoidNavigator, FormPresenterProtocol> {

    // MARK: - Overrided methods
    private var operativeData: UpdateNoSepaUsualTransferOperativeData?
    private var currentMode: NoSepaBankSelectorType!
    private var isBicType: Bool {
        return currentMode == .bicSwift
    }
    override var shouldShowProgress: Bool {
        return true
    }
    
    override var screenId: String? {
        return TrackerPagePrivate.UpdateUsualTransfer().noSepaExtraInput
    }
    
    override func loadViewData() {
        super.loadViewData()
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        currentMode = operativeData?.isBicType == true ? .bicSwift : .bankData
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_editFavoriteRecipients")
        view.backgroundColorProgressBar = .uiBackground
        
        generateSections()
    }
    
    private func generateSections() {
        guard let container = container else {
            return
        }
        operativeData = container.provideParameter()
        
        guard let sections = buildFieldsSection() else { return }
        view.dataSource.reloadSections(sections: sections)
        view.continueButton.set(localizedStylableText: stringLoader.getString("generic_button_continue"), state: .normal)
    }
    
    private func addTitleAndInput(into items: inout [StackItemProtocol], titleKey: String, identifier: String, currentValue: String?) {
        let location = TitleLabelStackModel(title: dependencies.stringLoader.getString(titleKey), insets: Insets(left: 11, right: 10, top: 30, bottom: 6))
        items.append(location)
        let destinationAddressModel = TextFieldStackModel(inputIdentifier: identifier, placeholder: nil, maxLength: 50)
        destinationAddressModel.setCurrentValue(currentValue ?? "")
        items.append(destinationAddressModel)
    }
    
    private func buildFieldsSection() -> [StackSection]? {
        let fixedSection = StackSection()
        var items: [StackItemProtocol] = []
        
        addTitleAndInput(into: &items, titleKey: "sendMoney_label_recipientsAddress", identifier: payeeAddressIdentifier, currentValue: operativeData?.payeeAddress)
        addTitleAndInput(into: &items, titleKey: "sendMoney_label_recipientsTown", identifier: payeeLocationIdentifier, currentValue: operativeData?.payeeLocation)
        addTitleAndInput(into: &items, titleKey: "sendMoney_label_destinationToCountry", identifier: payeeCountryIdentifier, currentValue: operativeData?.payeeCountry)

        let bankSelectorTitle = TitleLabelStackModel(title: dependencies.stringLoader.getString("sendMoney_label_bankIdentifier"))
        items.append(bankSelectorTitle)
        let bankMode: NoSepaBankSelectorType = isBicType ? .bicSwift : .bankData
        let bankSelectorModel = OptionsPickerStackModel(items: NoSepaBankSelectorType.allCases, selected: bankMode, dependencies: dependencies) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.currentMode = strongSelf.isBicType ? .bankData : .bicSwift
            self?.generateSections()
        }
        items.append(bankSelectorModel)
        
        if isBicType {
            addTitleAndInput(into: &items, titleKey: "confirmation_label_bicSwift", identifier: bicSwiftIdentifier, currentValue: operativeData?.bicSwift)
        } else {
            addTitleAndInput(into: &items, titleKey: "sendMoney_label_nameBank", identifier: bankNameIdentifier, currentValue: operativeData?.bankName)
            addTitleAndInput(into: &items, titleKey: "sendMoney_label_optionalAddress", identifier: bankAddressIdentifier, currentValue: operativeData?.bankAddress)
            addTitleAndInput(into: &items, titleKey: "sendMoney_label_optionalTown", identifier: bankLocationIdentifier, currentValue: operativeData?.bankLocation)
            addTitleAndInput(into: &items, titleKey: "sendMoney_label_country", identifier: bankCountryIdentifier, currentValue: operativeData?.bankCountry)
        }
        
        fixedSection.add(items: items)
        
        return [fixedSection]
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void, onError: @escaping (OperativeContainerDialog) -> Void) {
        guard let container = container else {
            return
        }
        let operativeData: UpdateNoSepaUsualTransferOperativeData = container.provideParameter()
        onSuccess(operativeData.isBicType == true || operativeData.isBankType == true)
    }
}

extension UpdateNoSepaUsualTransferBankDataPresenter: FormPresenterProtocol {
    func onContinueButtonClicked() {
        guard let operativeData = operativeData else {
            return
        }

        let newPayeeAddress: String? = view.dataSource.findData(identifier: payeeAddressIdentifier)
        let newPayeeLocation: String? = view.dataSource.findData(identifier: payeeLocationIdentifier)
        let newPayeeCountry: String? = view.dataSource.findData(identifier: payeeCountryIdentifier)
        var newBankName: String? = view.dataSource.findData(identifier: bankNameIdentifier)
        var newBankAddress: String? = view.dataSource.findData(identifier: bankAddressIdentifier)
        var newBankLocation: String? = view.dataSource.findData(identifier: bankLocationIdentifier)
        var newBankCountry: String? = view.dataSource.findData(identifier: bankCountryIdentifier)
        var newBicSwift: String? = view.dataSource.findData(identifier: bicSwiftIdentifier)
        switch currentMode {
        case .bankData?:
            newBicSwift = nil
        case .bicSwift?:
            newBankName = nil
            newBankAddress = nil
            newBankLocation = nil
            newBankCountry = nil
        default:
            break
        }

        operativeData.newEntryMode = currentMode
        operativeData.newPayeeAddress = newPayeeAddress
        operativeData.newPayeeLocation = newPayeeLocation
        operativeData.newPayeeCountry = newPayeeCountry
        operativeData.newBankName = newBankName
        operativeData.newBankAddress = newBankAddress
        operativeData.newBankLocation = newBankLocation
        operativeData.newBankCountry = newBankCountry
        operativeData.newBicSwift = newBicSwift
        
        let errorChecker = NoSepaFieldsBuilderFactory.create(operativeData)
        if let errorMessage = errorChecker.errorMessageForPayeeAndBankFields(data: operativeData) {
            showError(keyTitle: "generic_alert_title_errorData", keyDesc: errorMessage)
            return
        }
        
        container?.stepFinished(presenter: self)
    }
    
}

enum NoSepaBankSelectorType: CustomStringConvertible, CaseIterable {
    case bankData
    case bicSwift
    
    var description: String {
        switch self {
        case .bicSwift:
            return "sendMoney_label_bicSwift"
        case .bankData:
            return "sendMoney_hint_informationBankRecipient"
        }
    }
    var value: NoSepaTransferTypeLocal {
        switch self {
        case .bicSwift: return .bicSwift
        case .bankData: return .identifier
        }
    }
}

extension UpdateNoSepaUsualTransferBankDataPresenter: UpdateNoSepaOperativeSharedIdentifiers {}
