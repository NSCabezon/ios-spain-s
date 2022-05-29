import Foundation

struct AUInsuranceDataBuilder {
    
    private let dependencies: PresentationComponent
    private let shareDelegate: ShareInfoHandler
    
    init(dependencies: PresentationComponent, shareDelegate: ShareInfoHandler) {
        self.dependencies = dependencies
        self.shareDelegate = shareDelegate
    }
    
    func getGeneralData(_ insuranceData: InsuranceData, insuranceProtection: InsuranceProtection) -> [DateProvider] {
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
        //TODO: Uncomment when missing fields do show up on service. Should update SanLibrary version too.
//        if let carDescription = insuranceData.carDescription {
//            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurance_label_brandModel"), info: carDescription.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
//        }
//        if let driver = insuranceData.driver {
//            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurance_label_mainDriver"), info: driver.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
//        }
//        if let driver2 = insuranceData.driver2 {
//            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurance_label_aditionalDriver"), info: driver2.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
//        }
        data.last?.isLast = true
        result.append(contentsOf: data)
        let loading = SecondaryLoadingModelView(dependencies: dependencies)
        result.append(loading)
        return result
    }
}
