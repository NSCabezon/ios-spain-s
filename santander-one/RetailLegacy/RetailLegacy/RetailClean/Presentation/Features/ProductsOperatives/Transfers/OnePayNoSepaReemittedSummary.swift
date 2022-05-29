import Foundation

final class OnePayNoSepaReemittedSummary: OnePaySummaryInfo {
    private let operativeData: ReemittedNoSepaTransferOperativeData
    private let dependencies: PresentationComponent
    
    init(operativeData: ReemittedNoSepaTransferOperativeData, dependencies: PresentationComponent) {
        self.operativeData = operativeData
        self.dependencies = dependencies
    }
    
    func info() -> [SummaryItemData] {
        let builder = OnePaySummaryItemDataBuilder(operativeData: operativeData, dependencies: dependencies)
        builder.addType()
            .addOriginAccount()
            .addDestinationAccount()
            .addBeneficiary()
            .addDestinationCountry()
        switch operativeData.transferType {
        case .identifier?: builder.addBankName()
        case .bicSwift?: builder.addSwift()
        case .sepa?: break
        case .none: break
        }
        builder.addAmount()
        builder.addConcept()
        builder.addPeriodicity()
        builder.addTransactionDate()
        builder.addTotalExpenses()
        builder.addPayerSettlement()
        builder.addBeneficiarySettlement()
        return builder.build()
    }
}

// MARK: - SummaryItemBuilder

private class OnePaySummaryItemDataBuilder {
    let operativeData: ReemittedNoSepaTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(operativeData: ReemittedNoSepaTransferOperativeData, dependencies: PresentationComponent) {
        self.operativeData = operativeData
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addType() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_type"), value: dependencies.stringLoader.getString("summary_label_standar").text))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> OnePaySummaryItemDataBuilder {
        let accountText: String = operativeData.beneficiaryAccount?.account ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addOriginAccount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: operativeData.productSelected?.getAliasAndInfo() ?? ""))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: operativeData.transferDetail.payee?.name ?? ""))
        return self
    }
    
    @discardableResult
    func addAmount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: operativeData.noSepaTransferValidation?.settlementAmountBenef?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addConcept() -> OnePaySummaryItemDataBuilder {
        let concept: String
        if let transferConcept = operativeData.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept))
        return self
    }
    
    @discardableResult
    func addTransactionDate() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: Date(), outputFormat: .dd_MMM_yyyy) ?? ""))
        return self
    }
    
    @discardableResult
    func addDestinationCountry() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationCountry"), value: operativeData.selectedCountry?.name.capitalized ?? ""))
        return self
    }
    
    @discardableResult
    func addSwift() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_label_bicSwift"), value: operativeData.beneficiaryAccount?.bicSwift ?? ""))
        return self
    }
    
    @discardableResult
    func addBankName() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_nameBank"), value: operativeData.beneficiaryAccount?.bankName ?? ""))
        return self
    }
    
    @discardableResult
    func addPeriodicity() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: dependencies.stringLoader.getString("summary_label_timely").text))
        return self
    }
    
    @discardableResult
    func addTotalExpenses() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_label_totalExpenses"), value: operativeData.noSepaTransferValidation?.impTotComComp?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addBeneficiarySettlement() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_label_amountBeneficiaryPay"), value: operativeData.noSepaTransferValidation?.settlementAmountBenef?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addPayerSettlement() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_label_payerAmountToDebt"), value: operativeData.noSepaTransferValidation?.settlementAmountPayer?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
