import Foundation

public struct BillCollectionDTO: Codable  {
    public let productIdentifier: String
    public let typeCode: String
    public let code: String
    public let description: String
    public let operationTypeCode: String
    public let indicatorModifiesAmount: String
    public let indicatorModifiesCurrency: String
    
    public init?(productIdentifier: String, typeCode: String, code: String, description: String, operationTypeCode: String, indicatorModifiesAmount: String, indicatorModifiesCurrency: String) {
        self.productIdentifier = productIdentifier
        self.typeCode = typeCode
        self.code = code
        self.description = description
        self.operationTypeCode = operationTypeCode
        self.indicatorModifiesAmount = indicatorModifiesAmount
        self.indicatorModifiesCurrency = indicatorModifiesCurrency
    }
}
