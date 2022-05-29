import SANLegacyLibrary

struct InsuranceData {
    
    var familyId: String? {
        return dto.familyId
    }
    
    var factoryName: String? {
        return dto.factoryName
    }
    
    var familyDescription: String? {
        return dto.familyDescription
    }
    
    var productName: String? {
        return dto.productName
    }
    
    var policyId: String? {
        return dto.policyId
    }
    
    var effectiveDate: String? {
        return dto.effectiveDate
    }
    
    var dueDate: String? {
        return dto.dueDate
    }
    
    var accountId: String? {
        return dto.accountId
    }
    
    var initialFee: Amount? {
        return dto.initialFee != nil ? Amount.createFromDTO(dto.initialFee) : nil
    }
    
    var periodicRemittance: Amount? {
        return dto.periodicRemittance != nil ? Amount.createFromDTO(dto.periodicRemittance) : nil
    }
    
    var payMethodDescription: String? {
        return dto.payMethodDescription
    }
    
    var totalAmount: Amount? {
        return dto.totalAmount != nil ? Amount.createFromDTO(dto.totalAmount) : nil
    }
    
    var remittanceNumber: String? {
        return dto.remittanceNumber
    }
    
    var marketValueAmount: Amount? {
        return dto.marketValueAmount != nil ? Amount.createFromDTO(dto.marketValueAmount) : nil
    }
    
    var installmentAccountId: String? {
        return dto.installmentAccountId
    }
    
    var insuredAmount: Amount? {
        return dto.insuredAmount != nil ? Amount.createFromDTO(dto.insuredAmount) : nil
    }
    
    var lastReceiptAmount: Amount? {
        return dto.lastReceiptAmount != nil ? Amount.createFromDTO(dto.lastReceiptAmount) : nil
    }
    
    var propertyType: String? {
        return dto.propertyType
    }
    
    var propertyUse: String? {
        return dto.propertyUse
    }
    
    var address: String? {
        return dto.address
    }
    
    var town: String? {
        return dto.town
    }
    
    var buildingsAmount: Amount? {
        return dto.buildingsAmount != nil ? Amount.createFromDTO(dto.buildingsAmount) : nil
    }
    
    var contentsAmount: Amount? {
        return dto.contentsAmount != nil ? Amount.createFromDTO(dto.contentsAmount) : nil
    }
    
    var specialObjectsAmount: Amount? {
        return dto.specialObjectsAmount != nil ? Amount.createFromDTO(dto.specialObjectsAmount) : nil
    }
    
    var thirdPartyInd: String? {
        return dto.thirdPartyInd
    }
    
    var factoryPolicyNumber: String? {
        return dto.factoryPolicyNumber
    }
    
    var healthCardNumber: String? {
        return dto.healthCardNumber
    }
    
    //TODO: Uncomment when missing fields do show up on service. Should update SanLibrary version too.
//    var carDescription: String? {
//        return dto.carDescription
//    }
//
//    var driver: String? {
//        return dto.driver
//    }
//
//    var driver2: String? {
//        return dto.driver2
//    }
//
//    var numberInsuredAddresses: String? {
//        return dto.numberInsuredAddresses
//    }
    
    private(set) var dto: InsuranceDataDTO
    
    init(_ dto: InsuranceDataDTO) {
        self.dto = dto
    }
}
