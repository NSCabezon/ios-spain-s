import Foundation

let afirstLimitDate = "0001-01-01"
let aendLimitDate = "9999-12-31"

struct DefaultSavingInsuranceDataBuilder {
    
    private let dependencies: PresentationComponent
    private let shareDelegate: ShareInfoHandler
    
    init(dependencies: PresentationComponent, shareDelegate: ShareInfoHandler) {
        self.dependencies = dependencies
        self.shareDelegate = shareDelegate
    }
    
    func getDataForDefaultInsurance(_ insuranceData: InsuranceData, insuranceSaving: InsuranceSaving) -> [DateProvider] {
        
        var result = [DateProvider]()
        
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_generalData").uppercased(), dependencies, nil, false)
        result.append(header)
        
        var data = [InsuranceGeneralDataViewModel]()
        if let factoryName = insuranceData.factoryName {
            data.append(InsuranceGeneralDataViewModel(isFirst: true, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_company"), info: factoryName.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let familyDescription = insuranceData.familyDescription {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_family"), info: familyDescription.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let productName = insuranceData.productName {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_productType"), info: productName.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if !insuranceSaving.getDetailUI().isEmpty {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: true, infoTitle: dependencies.stringLoader.getString("insurances_label_policyNumber"), info: insuranceSaving.getPolicyNumber() ?? "", privateComponent: dependencies, copyTag: 2, shareDelegate: shareDelegate))
        }
        
        if let effectiveDate = insuranceData.effectiveDate, effectiveDate != endLimitDate && effectiveDate != firstLimitDate, let toString = dependencies.timeManager.toString(input: effectiveDate, inputFormat: TimeFormat.yyyyMMdd, outputFormat: TimeFormat.d_MMM_yyyy) {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_effectiveDate"), info: toString.lowercased(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let dueDate = insuranceData.dueDate, dueDate != endLimitDate && dueDate != firstLimitDate, let toString = dependencies.timeManager.toString(input: dueDate, inputFormat: TimeFormat.yyyyMMdd, outputFormat: TimeFormat.d_MMM_yyyy) {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_expiryDate"), info: toString.lowercased(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let accountId = insuranceData.accountId {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: true, infoTitle: dependencies.stringLoader.getString("insurances_label_accountId"), info: accountId, privateComponent: dependencies, copyTag: 3, shareDelegate: shareDelegate))
        }
        
        if let payMethodDescription = insuranceData.payMethodDescription {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_payMethod"), info: payMethodDescription.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let lastReceiptAmount = insuranceData.lastReceiptAmount {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: true, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_premiumInsurances"), info: lastReceiptAmount.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        data.last?.isLast = true
        
        result.append(contentsOf: data)
        
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        result.append(loading)
        
        return result
    }
    
    func getParticipantsDataForDefaultInsurance(_ participants: InsuranceParticipantList) -> [DateProvider] {
        var result = [DateProvider]()
        
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_participants"), dependencies, nil, false)
        result.append(header)
        
        var index = 0
        for participant in participants.list {
            result.append(InsuranceInfoViewModel(isFirst: index == 0, isLast: index == participants.list.count - 1, infoTitle: "\(participant.name?.capitalized ?? "") \(participant.surname1?.capitalized ?? "") \(participant.surname2?.capitalized ?? "")", info: "", privateComponent: dependencies))
            index += 1
        }
        
        return result
    }
    
    func getBeneficiariesDataForDefaultInsurance(_ beneficiaries: InsuranceBeneficiaryList) -> [DateProvider] {
        var result = [DateProvider]()
        
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_beneficiaries"), dependencies, nil, false)
        result.append(header)
        
        var index = 0
        for beneficiary in beneficiaries.list {
            result.append(InsuranceInfoViewModel(isFirst: index == 0, isLast: index == beneficiaries.list.count - 1, infoTitle: beneficiary.name ?? "", info: beneficiary.type?.camelCasedString ?? "", privateComponent: dependencies))
            index += 1
        }
        
        return result
    }
}
