public struct AccountFutureBillParams: Codable {
    let iban: String
    let status: String
    let numberOfElements: Int
    let page: Int
    
    public init(iban: String, status: String, numberOfElements: Int, page: Int) {
        self.iban = iban
        self.status = status
        self.numberOfElements = numberOfElements
        self.page = page
    }
    
    enum CodingKeys: String, CodingKey {
        case iban = "accountNumber"
        case status = "status"
        case numberOfElements = "size"
        case page = "page"
    }
}
