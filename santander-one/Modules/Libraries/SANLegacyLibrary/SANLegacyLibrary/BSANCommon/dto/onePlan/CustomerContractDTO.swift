public struct CustomerContractDTO: Codable {
    public let productSubtype: String
    public let productType: String
    
    enum CodingKeys: String, CodingKey {
        case productType = "cdsprod"
        case productSubtype = "cdprods"
    }
}
