import SwiftyJSON

public struct LoanSimulatorLimitDTO: Codable, RestParser {
    public let purposeList: [LoanSimulatorLimitManagerPurposeDTO]?
    
    public init(json: JSON) {
        self.purposeList = LoanSimulatorLimitDTO.parsePurposeList(json: json)
    }
    
    private static func parsePurposeList(json: JSON) -> [LoanSimulatorLimitManagerPurposeDTO]? {
        let purposeListJSON = json["purposeList"]
        return purposeListJSON != JSON.null ? purposeListJSON.array?.map{ LoanSimulatorLimitManagerPurposeDTO(json: $0) } : nil
    }
}

public struct LoanSimulatorLimitManagerPurposeDTO: Codable, RestParser {
    public let purposeCode: String?
    public let longDescription: String?
    public let productsList: [LoanSimulatorProductLimitsDTO]?
    
    public init(json: JSON) {
        self.purposeCode = json["purposeCode"].string
        self.longDescription = json["longDescription"].string
        self.productsList = LoanSimulatorLimitManagerPurposeDTO.parseProductList(json: json)
    }
    
    private static func parseProductList(json: JSON) -> [LoanSimulatorProductLimitsDTO]? {
        let productListJSON = json["productsList"]
        return productListJSON != JSON.null ? productListJSON.array?.map{ LoanSimulatorProductLimitsDTO(json: $0) } : nil
    }
}

public struct LoanSimulatorProductLimitsDTO: Codable, RestParser {
    public let companyId: String?
    public let productCode: String?
    public let subTypeProduct: String?
    public let standardReference: String?
    public let amountFrom: Int?
    public let amountUntil: Int?
    public let termUntil: Int?
    public let termFrom: Int?
    public let defaultAmount: Int?
    public let defaultTerm: Int?
    public let bonusIndicator: String?
    public let bonusDifferential: Int?
    public let maximumFee: Int?
    
    public init(json: JSON) {
        self.companyId = json["companyId"].string
        self.productCode = json["productCode"].string
        self.subTypeProduct = json["subTypeProduct"].string
        self.standardReference = json["standardReference"].string
        self.amountFrom = json["amountFrom"].int
        self.amountUntil = json["amountUntil"].int
        self.termUntil = json["termUntil"].int
        self.termFrom = json["termFrom"].int
        self.defaultAmount = json["defaultAmount"].int
        self.defaultTerm = json["defaultTerm"].int
        self.bonusIndicator = json["bonusIndicator"].string
        self.bonusDifferential = json["bonusDifferential"].int
        self.maximumFee = json["maximumFee"].int
    }
}
