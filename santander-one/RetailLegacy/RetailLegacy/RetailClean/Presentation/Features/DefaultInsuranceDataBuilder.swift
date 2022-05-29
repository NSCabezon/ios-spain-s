import Foundation

let firstLimitDate = "0001-01-01"
let endLimitDate = "9999-12-31"

struct DefaultInsuranceDataBuilder {
    private let dependencies: PresentationComponent
    private let shareDelegate: ShareInfoHandler
    
    init(dependencies: PresentationComponent, shareDelegate: ShareInfoHandler) {
        self.dependencies = dependencies
        self.shareDelegate = shareDelegate
    }
    
    func getDataForDefaultInsurance(_ insuranceData: InsuranceData, insuranceProtection: InsuranceProtection) -> [DateProvider] {
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
        if !insuranceProtection.getDetailUI().isEmpty {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: true, infoTitle: dependencies.stringLoader.getString("insurances_label_policyNumber"), info: insuranceProtection.getDetailUI(), privateComponent: dependencies, copyTag: 2, shareDelegate: shareDelegate))
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
    
    func getDefaultCoverageData(_ coverages: InsuranceCoverageList) -> [DateProvider] {
        var result = [DateProvider]()
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_coverages"), dependencies, nil, false)
        result.append(header)
        for (index, coverage) in coverages.list.enumerated() {
            let infoTitle = LocalizedStylableText(text: coverage.name?.capitalizingFirstLetter() ?? "", styles: nil)
            result.append(InsuranceGeneralDataViewModel(isFirst: index == 0, isLast: index == coverages.list.count - 1, isCopiable: false, infoTitle: infoTitle, info: coverage.insuredAmount?.getFormattedAmountUIWith1M() ?? "", privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        return result
    }
    
    func getParticipantsDataForDefaultHealthInsurance(_ participants: InsuranceParticipantList) -> [DateProvider] {
        var result = [DateProvider]()
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_participants"), dependencies, nil, false)
        result.append(header)
        for (index, participant) in participants.list.enumerated() {
            result.append(InsuranceInfoViewModel(isFirst: index == 0, isLast: index == participants.list.count - 1, infoTitle: "\(participant.name?.capitalized ?? "") \(participant.surname1?.capitalized ?? "") \(participant.surname2?.capitalized ?? "")", info: "", privateComponent: dependencies))
        }
        return result
    }
    
    func getBeneficiariesDataForDefaultInsurance(_ beneficiaries: InsuranceBeneficiaryList) -> [DateProvider] {
        var result = [DateProvider]()
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_beneficiaries"), dependencies, nil, false)
        result.append(header)
        for (index, beneficiary) in beneficiaries.list.enumerated() {
            result.append(InsuranceInfoViewModel(isFirst: index == 0, isLast: index == beneficiaries.list.count - 1, infoTitle: beneficiary.name ?? "", info: beneficiary.type?.camelCasedString ?? "", privateComponent: dependencies))
        }
        return result
    }
    
    func getHeaderInfo(_ insuranceData: InsuranceData) -> ProductInsuranceHeader.ExtraInfo {
        var insuranceFamily: String?
        var insuranceName: String?
        if let familyDescription = insuranceData.familyDescription {
            insuranceFamily = dependencies.stringLoader.getString("insurances_label_insuranceType", [StringPlaceholder(.value, familyDescription)]).text
        }
        if let productName = insuranceData.productName, let factoryName = insuranceData.factoryName {
            insuranceName = productName + " - " + factoryName
        } else if let productName = insuranceData.productName {
            insuranceName = productName
        } else if let factoryName = insuranceData.factoryName {
            insuranceName = factoryName
        }
        return ProductInsuranceHeader.ExtraInfo(insuranceFamily: insuranceFamily, insuranceName: insuranceName, info: nil)
    }
}
