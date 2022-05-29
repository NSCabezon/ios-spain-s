import Foundation

struct ASInsuranceDataBuilder {
    
    private let dependencies: PresentationComponent
    private let shareDelegate: ShareInfoHandler
    
    init(dependencies: PresentationComponent, shareDelegate: ShareInfoHandler) {
        self.dependencies = dependencies
        self.shareDelegate = shareDelegate
    }
    
    func getDataForASInsurance(_ insuranceData: InsuranceData, insuranceSaving: InsuranceSaving) -> [DateProvider] {
        
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
        
        // Factory policy number
        if !insuranceSaving.getDetailUI().isEmpty {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: true, infoTitle: dependencies.stringLoader.getString("insurances_label_policyNumber"), info: insuranceSaving.getDetailUI(), privateComponent: dependencies, copyTag: 2, shareDelegate: shareDelegate))
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
        
        if let initialFee = insuranceData.initialFee {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_initialFee"), info: initialFee.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let periodicRemittance = insuranceData.periodicRemittance {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_periodicRemittance"), info: periodicRemittance.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let payMethodDescription = insuranceData.payMethodDescription {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_payPeriodicyType"), info: payMethodDescription.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let remittanceNumber = insuranceData.remittanceNumber {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_remittanceNumber"), info: remittanceNumber, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let installmentAccountId = insuranceData.installmentAccountId {
             data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: true, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_installmentAccountId"), info: installmentAccountId, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        data.last?.isLast = true
        
        result.append(contentsOf: data)

        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        result.append(loading)
        
        return result
        
    }
    
    func getParticipantsDataForASInsurance(_ participants: InsuranceParticipantList) -> [DateProvider] {
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
    
    func getBeneficiariesDataForASInsurance(_ beneficiaries: InsuranceBeneficiaryList) -> [DateProvider] {
        var result = [DateProvider]()
        
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_beneficiaries"), dependencies, nil, false)
        result.append(header)
        
        var index = 0
        for beneficiary in beneficiaries.list {
            result.append(InsuranceInfoViewModel(isFirst: index == 0, isLast: index == beneficiaries.list.count - 1, infoTitle: beneficiary.name ?? "", info: beneficiary.type?.capitalized ?? "", privateComponent: dependencies))
            index += 1
        }
        
        return result
    }

}
