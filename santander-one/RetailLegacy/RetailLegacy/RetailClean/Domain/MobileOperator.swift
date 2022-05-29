import SANLegacyLibrary

struct MobileOperator: OperativeParameter, CustomStringConvertible {
    let operatorDTO: MobileOperatorDTO
    
    init(_ mobileOperatorDTO: MobileOperatorDTO) {
        self.operatorDTO = mobileOperatorDTO
    }
    
    var name: String? {
        return operatorDTO.name
    }
    
    var description: String {
        return name ?? ""
    }
    
    var code: String? {
        return operatorDTO.code
    }
    
    var maximumAmount: Amount? {
        return Amount.createFromDTO(operatorDTO.maxAmount)
    }
    
    var minimumAmount: Amount? {
        return Amount.createFromDTO(operatorDTO.minAmount)
    }
    
    var sectionAmount: Amount? {
        return Amount.createFromDTO(operatorDTO.sectionAmount)
    }
}
