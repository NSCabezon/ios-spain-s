//

import Foundation
import CoreFoundationLib

protocol OnePaySummaryInfo {
    func info() -> [SummaryItemData]
}

final class OnePaySepaSummaryInfo: OnePaySummaryInfo {
    
    private let operativeData: OnePayTransferOperativeData
    private let dependencies: PresentationComponent
    
    init(operativeData: OnePayTransferOperativeData, dependencies: PresentationComponent) {
        self.operativeData = operativeData
        self.dependencies = dependencies
    }
    
    func info() -> [SummaryItemData] {
        let builder = OnePaySummaryItemDataBuilder(operativeData: operativeData, dependencies: dependencies)
        builder.addType()
            .addOriginAccount()
            .addDestinationAccount()
            .addBeneficiary()
            .addAmount()
            .addConcept()
        
        switch operativeData.time {
        case .now?:
            builder.addPeriodicity()
                .addTransactionDate()
                .addBankChargeAmount()
                .addMailExpenses()
                .addNetAmount()
        case .day?:
            builder.addPeriodicity()
                .addIssuanceDate()
                .addBankChargeAmount()
        case .periodic?:
            builder.addPeriodicity()
                .addStartAndEndDate()
                .addBankChargeAmount()
        case .none:
            break
        }
        return builder.build()
    }
}

// MARK: - SummaryItemBuilder

private class OnePaySummaryItemDataBuilder {
    
    let operativeData: OnePayTransferOperativeData
    let dependencies: PresentationComponent
    private var fields: [SummaryItemData] = []
    
    init(operativeData: OnePayTransferOperativeData, dependencies: PresentationComponent) {
        self.operativeData = operativeData
        self.dependencies = dependencies
    }
    
    @discardableResult
    func addType() -> OnePaySummaryItemDataBuilder {
        let typeKey: String
        switch operativeData.time {
        case .now?:
            typeKey = operativeData.subType?.description ?? "summary_label_standar"
        case .day?:
            typeKey = "summary_label_standardProgrammed"
        case .periodic?:
            typeKey = "summary_label_standardProgrammed"
        case .none:
            typeKey = ""
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_type"), value: dependencies.stringLoader.getString(typeKey).text))
        return self
    }
    
    @discardableResult
    func addDestinationAccount() -> OnePaySummaryItemDataBuilder {
        let accountText: String = operativeData.iban?.formatted ?? ""
        let wrapType: SimpleSummaryDataWrapType = IbanSummaryWrap.getWrapType(text: accountText)
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_destinationAccountsTransfer"), value: accountText, wrapType: wrapType))
        return self
    }
    
    @discardableResult
    func addOriginAccount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: operativeData.productSelected?.getAliasAndInfo() ?? operativeData.iban?.getAliasAndInfo(withCustomAlias: dependencies.stringLoader.getString("generic_summary_associatedAccount").text) ?? ""))
        return self
    }
    
    @discardableResult
    func addBeneficiary() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: "\(operativeData.name ?? "")"))
        return self
    }
    
    @discardableResult
    func addAmount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: operativeData.amount?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addConcept() -> OnePaySummaryItemDataBuilder {
        let concept: String
        if let transferConcept = operativeData.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            switch operativeData.time {
            case .day?, .periodic?:
                concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
            case .now?, nil:
                concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
            }
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept))
        return self
    }
    
    @discardableResult
    func addTransactionDate() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_transactionDate"), value: dependencies.timeManager.toString(date: operativeData.transferNational?.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""))
        return self
    }
    
    @discardableResult
    func addBankChargeAmount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_commission"), value: operativeData.transferNational?.bankChargeAmount?.getAbsFormattedAmountUI() ?? operativeData.scheduledTransfer?.bankChargeAmount?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addMailExpenses() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_mailExpenses"), value: operativeData.transferNational?.expensesAmount?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addNetAmount() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amountToDebt"), value: operativeData.transferNational?.netAmount?.getAbsFormattedAmountUI() ?? ""))
        return self
    }
    
    @discardableResult
    func addPeriodicity() -> OnePaySummaryItemDataBuilder {
        let periodicity: String
        switch operativeData.time {
        case .day?:
            periodicity = dependencies.stringLoader.getString("summary_label_delayed").text
        case .periodic(_, _, let periodicityValue, _)?:
            switch periodicityValue {
            case .monthly: periodicity = dependencies.stringLoader.getString("summary_label_monthly").text
            case .quarterly: periodicity = dependencies.stringLoader.getString("summary_label_quarterly").text
            case .biannual: periodicity = dependencies.stringLoader.getString("summary_label_sixMonthly").text
            case .weekly: periodicity = dependencies.stringLoader.getString("summary_label_weekly").text
            case .bimonthly: periodicity = dependencies.stringLoader.getString("summary_label_bimonthly").text
            case .annual: periodicity = dependencies.stringLoader.getString("summary_label_annual").text
            }
        case .now?:
            periodicity = dependencies.stringLoader.getString("summary_label_timely").text
        default:
            periodicity = dependencies.stringLoader.getString("summary_label_standar").text
        }
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: periodicity))
        return self
    }
    
    @discardableResult
    func addStartAndEndDate() -> OnePaySummaryItemDataBuilder {
        switch operativeData.time {
        case .periodic(let startDate, let endDate, _, _)?:
            let issueDate = dependencies.timeManager.toString(date: startDate, outputFormat: .dd_MMM_yyyy)
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_startDate"), value: issueDate ?? ""))
            let endDateValue: String
            switch endDate {
            case .date(let date):
                endDateValue = dependencies.timeManager.toString(date: date, outputFormat: .dd_MMM_yyyy) ?? ""
            case .never:
                endDateValue = dependencies.stringLoader.getString("detailsOnePay_label_indefinite").text
            }
            fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_endDate"), value: endDateValue))
        default: break
        }
        return self
    }
    
    @discardableResult
    func addIssuanceDate() -> OnePaySummaryItemDataBuilder {
        fields.append(SimpleSummaryData(field: dependencies.stringLoader.getString("sendMoney_label_issuanceDate"), value: dependencies.timeManager.toString(date: operativeData.issueDate, outputFormat: .dd_MMM_yyyy) ?? ""))
        return self
    }
    
    func build() -> [SummaryItemData] {
        return fields
    }
}
