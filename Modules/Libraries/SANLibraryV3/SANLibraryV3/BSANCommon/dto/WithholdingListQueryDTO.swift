public struct WithholdingListQueryDTO: Encodable {
    public let iban: String
    public let currency: String
    
    enum CodingKeys: String, CodingKey {
        case iban = "iban"
        case currency = "divisa"
    }
}
