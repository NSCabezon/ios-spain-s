import Foundation

struct HomeInsuranceDataBuilder {
    
    private let dependencies: PresentationComponent
    private let shareDelegate: ShareInfoHandler
    
    init(dependencies: PresentationComponent, shareDelegate: ShareInfoHandler) {
        self.dependencies = dependencies
        self.shareDelegate = shareDelegate
    }
    
    func getDataForHomeInsurance(_ insuranceData: InsuranceData, insuranceProtection: InsuranceProtection) -> [DateProvider] {
        
        var result = [DateProvider]()
        
        let header = TransactionFilterModelView(dependencies.stringLoader.getString("insurances_label_generalData").uppercased(), dependencies, nil, false)
        result.append(header)
        
        var data = [InsuranceGeneralDataViewModel]()

        if let effectiveDate = insuranceData.effectiveDate, effectiveDate != endLimitDate && effectiveDate != firstLimitDate, let toString = dependencies.timeManager.toString(input: effectiveDate, inputFormat: TimeFormat.yyyyMMdd, outputFormat: TimeFormat.d_MMM_yyyy) {
            data.append(InsuranceGeneralDataViewModel(isFirst: true, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_effectiveDate"), info: toString.lowercased(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }

        if let dueDate = insuranceData.dueDate, dueDate != endLimitDate && dueDate != firstLimitDate, let toString = dependencies.timeManager.toString(input: dueDate, inputFormat: TimeFormat.yyyyMMdd, outputFormat: TimeFormat.d_MMM_yyyy) {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_expiryDate"), info: toString.lowercased(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let payMethodDescription = insuranceData.payMethodDescription {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_payMethod"), info: payMethodDescription.camelCasedString, privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let accountId = insuranceData.accountId {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: true, infoTitle: dependencies.stringLoader.getString("insurances_label_accountId"), info: accountId, privateComponent: dependencies, copyTag: 3, shareDelegate: shareDelegate))
        }
        
        if let buildingsAmount = insuranceData.buildingsAmount, buildingsAmount.value?.doubleValue != 0 {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_buildingsAmount"), info: buildingsAmount.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let contentsAmount = insuranceData.contentsAmount, contentsAmount.value?.doubleValue != 0 {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_contentsAmount"), info: contentsAmount.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let specialObjectsAmount = insuranceData.specialObjectsAmount, specialObjectsAmount.value?.doubleValue != 0 {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_specialObjectsAmount"), info: specialObjectsAmount.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        if let lastReceiptAmount = insuranceData.lastReceiptAmount {
            data.append(InsuranceGeneralDataViewModel(isFirst: false, isLast: false, isCopiable: false, infoTitle: dependencies.stringLoader.getString("insurances_label_premiumInsurances"), info: lastReceiptAmount.getFormattedAmountUIWith1M(), privateComponent: dependencies, shareDelegate: shareDelegate))
        }
        
        data.last?.isLast = true
        
        result.append(contentsOf: data)
        
        return result
    }
    
    func getHeaderInfo(_ insuranceData: InsuranceData) -> ProductInsuranceHeader.ExtraInfo {
        var insuranceFamily: String?
        var insuranceName: String?
        var info: InsuranceBottomInfo?
        
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
        
        if let address = insuranceData.address {
            info = InsuranceBottomInfo.protection(
                attributeTitle: dependencies.stringLoader.getString("insurances_label_addressInsured").text,
                attributeValue: address)
        }
        
        return ProductInsuranceHeader.ExtraInfo(insuranceFamily: insuranceFamily, insuranceName: insuranceName, info: info)
    }
}
