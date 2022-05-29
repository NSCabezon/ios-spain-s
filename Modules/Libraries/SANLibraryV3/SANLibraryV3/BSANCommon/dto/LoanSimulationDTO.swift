import Foundation

public struct LoanSimulationDTO: Codable {
    public let companyId: String?
    public let centerId: String?
    public let currency: String?
    public let productCode: String?
    public let productSubType: String?
    public let productStandard: String?
    public let amount: Int?
    public let insuranceSimFlag: String?
    public let term: Int?
    public let maximumFee: Int?

    enum CodingKeys: String, CodingKey {
        case companyId = "companyId"
        case centerId = "centerId"
        case currency = "currency"
        case productCode = "productCode"
        case productSubType = "productSubType"
        case productStandard = "productStandard"
        case amount = "amount"
        case insuranceSimFlag = "insuranceSimFlag"
        case term = "term"
        case maximumFee = "maximumFee"
    }

    public init(companyId: String?, centerId: String?, currency: String?, productCode: String?, productSubType: String?, productStandard: String?, amount: Int?, insuranceSimFlag: String?, term: Int?, maximumFee: Int?) {
        self.companyId = companyId
        self.centerId = centerId
        self.currency = currency
        self.productCode = productCode
        self.productSubType = productSubType
        self.productStandard = productStandard
        self.amount = amount
        self.insuranceSimFlag = insuranceSimFlag
        self.term = term
        self.maximumFee = maximumFee
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(companyId, forKey: .companyId)
        try container.encode(centerId, forKey: .centerId)
        try container.encode(currency, forKey: .currency)
        try container.encode(productCode, forKey: .productCode)
        try container.encode(productSubType, forKey: .productSubType)
        try container.encode(productStandard, forKey: .productStandard)
        try container.encode(amount, forKey: .amount)
        try container.encode(insuranceSimFlag, forKey: .insuranceSimFlag)
        try container.encode(term, forKey: .term)
        try container.encode(maximumFee, forKey: .maximumFee)
    }
}
