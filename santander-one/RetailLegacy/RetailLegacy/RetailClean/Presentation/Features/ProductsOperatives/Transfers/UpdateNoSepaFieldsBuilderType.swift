struct NoSepaFieldsBuilderFactory {
    static func create(_ data: UpdateNoSepaUsualTransferOperativeData) -> UpdateNoSepaFieldsBuilderType {
        if let newEntryMode = data.newEntryMode {
            switch newEntryMode {
            case .bankData:
                return NoSepaBankData()
            case .bicSwift:
                return NoSepaSwift()
            }
        } else if data.isBankType {
            return NoSepaBankData()
        } else if data.isBicType {
            return NoSepaSwift()
        } else {
            return NoSepaIban()
        }
    }
}

protocol UpdateNoSepaFieldsBuilderType {
    func createConfirmationFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [ConfirmationTableViewItemModel]
    func createSummaryFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [SummaryItemData]
    func errorMessageForPayeeAndBankFields(data: UpdateNoSepaUsualTransferOperativeData) -> String?
}

struct NoSepaSwift: UpdateNoSepaFieldsBuilderType {
    
    func errorMessageForPayeeAndBankFields(data: UpdateNoSepaUsualTransferOperativeData) -> String? {
        if (data.newBicSwift == nil || data.newBicSwift?.isEmpty == true) && data.newEntryMode == .bicSwift {
            return "onePay_alert_bicSwift"
        }
        if data.newPayeeCountry == nil || data.newPayeeCountry?.isEmpty == true {
            return "onePay_alert_destinationToCountry"
        }
        
        return nil
    }
    
    func createSummaryFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [SummaryItemData] {
        let builder = UpdateUsualTransferSummaryItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addPayeeName()
        builder.addDestinationAccount()
        builder.addDestinationCountry()
        builder.addCurrency()
        builder.addBicSwift()
        return builder.build()
    }
    
    func createConfirmationFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [ConfirmationTableViewItemModel] {
        let builder = UpdateUsualTransferItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addHolder()
        builder.addDestinationAccount()
        builder.addPayeeAddress()
        builder.addPayeeLocation()
        builder.addPayeeCountry()
        builder.addTransferDestinationCountry()
        builder.addCurrency()
        builder.addBicSwift()
        return builder.build(withFirstElement: true)
    }
    
}

struct NoSepaBankData: UpdateNoSepaFieldsBuilderType {
    
    func errorMessageForPayeeAndBankFields(data: UpdateNoSepaUsualTransferOperativeData) -> String? {
        if data.newPayeeCountry == nil || data.newPayeeCountry?.isEmpty == true {
            return "onePay_alert_destinationToCountry"
        }
        if data.newBankName == nil || data.newBankName?.isEmpty == true {
            return "onePay_alert_nameBank"
        }
        return nil
    }
    
    func createSummaryFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [SummaryItemData] {
        let builder = UpdateUsualTransferSummaryItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addPayeeName()
        builder.addDestinationAccount()
        builder.addDestinationCountry()
        builder.addCurrency()
        builder.addBankName()
        return builder.build()
    }
    
    func createConfirmationFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [ConfirmationTableViewItemModel] {
        let builder = UpdateUsualTransferItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addHolder()
        builder.addDestinationAccount()
        builder.addPayeeAddress()
        builder.addPayeeLocation()
        builder.addPayeeCountry()
        builder.addTransferDestinationCountry()
        builder.addCurrency()
        builder.addBankName()
        builder.addBankAddress()
        builder.addBankLocation()
        builder.addBankCountry()
        return builder.build(withFirstElement: true)
    }
    
}

struct NoSepaIban: UpdateNoSepaFieldsBuilderType {
    
    func errorMessageForPayeeAndBankFields(data: UpdateNoSepaUsualTransferOperativeData) -> String? {
        return nil
    }
    
    func createSummaryFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [SummaryItemData] {
        let builder = UpdateUsualTransferSummaryItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addPayeeName()
        builder.addDestinationAccount()
        builder.addDestinationCountry()
        builder.addCurrency()
        return builder.build()
    }
    
    func createConfirmationFields(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) -> [ConfirmationTableViewItemModel] {
        let builder = UpdateUsualTransferItemsBuilder(data: data, dependencies: dependencies)
        builder.addAlias()
        builder.addHolder()
        builder.addDestinationAccount()
        builder.addTransferDestinationCountry()
        builder.addCurrency()
        return builder.build(withFirstElement: true)
    }
    
}

private class UpdateUsualTransferSummaryItemsBuilder {
    
    private let data: UpdateNoSepaUsualTransferOperativeData
    private let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = [SummaryItemData]()
    
    init(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) {
        self.data = data
        self.dependencies = dependencies
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
    
    func addAlias() {
        add(key: "summary_item_alias", value: (data.payeeAlias?.camelCasedString))
    }
    
    func addPayeeName() {
        add(key: "summary_item_beneficiary", value: data.newName)
    }
    
    func addDestinationAccount() {
        let accountText: String = data.newDestinationAccount ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        let item = SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType)
        fields.append(item)
    }
    
    func addDestinationCountry() {
        add(key: "summary_item_destinationCountry", value: data.transferCountry)
    }
    
    func addCurrency() {
        add(key: "summary_item_currency", value: data.payeeCurrency)
    }
    
    func addBicSwift() {
        add(key: "summary_label_bicSwift", value: data.newBicSwift)
    }
    
    func addBankName() {
        add(key: "summary_item_nameBank", value: data.newBankName)
    }
    
    private func add(key: String, value: String?) {
        guard let value = value else {
            return
        }
        let item = SimpleSummaryData(field: dependencies.stringLoader.getString(key), value: value)
        fields.append(item)
    }
}

private class UpdateUsualTransferItemsBuilder: ConfirmationBuilder {
    
    private let data: UpdateNoSepaUsualTransferOperativeData
    
    init(data: UpdateNoSepaUsualTransferOperativeData, dependencies: PresentationComponent) {
        self.data = data
        super.init(dependencies: dependencies)
    }
    
    func addAlias() {
        add("confirmation_item_alias", string: data.payeeAlias)
    }
    
    func addHolder() {
        add("confirmation_item_holder", string: data.newName)
    }
    
    func addDestinationAccount() {
        add("confirmation_item_destinationAccount", string: data.newDestinationAccount)
    }
    
    func addPayeeAddress() {
        add("confirmation_label_beneficiaryAddress", string: data.newPayeeAddress)
    }
    
    func addPayeeLocation() {
        add("confirmation_label_beneficiaryTown", string: data.newPayeeLocation)
    }
    
    func addPayeeCountry() {
        add("confirmation_label_beneficiaryCountry", string: data.newPayeeCountry)
    }
    
    func addCurrency() {
        add("confirmation_item_currency", string: data.payeeCurrency)
    }
    
    func addBicSwift() {
        add("confirmation_label_bicSwift", string: data.newBicSwift)
    }
    
    func addBankCountry() {
        add("confirmation_item_country", string: data.newBankCountry)
    }
    
    func addBankName() {
        add("confirmation_item_nameBank", string: data.newBankName)
    }
    
    func addBankAddress() {
        add("confirmation_item_address", string: data.newBankAddress)
    }
    
    func addBankLocation() {
        add("confirmation_item_town", string: data.newBankLocation)
    }
    
    func addTransferDestinationCountry() {
        add("confirmation_item_destinationCountry", string: data.transferCountry)
    }
    
    override func add(_ titleKey: String, string: String?, valueLines: Int = 1) {
        guard let string = string, !string.isEmpty else {
            return
        }
        super.add(titleKey, string: string, valueLines: valueLines)
    }
    
}
