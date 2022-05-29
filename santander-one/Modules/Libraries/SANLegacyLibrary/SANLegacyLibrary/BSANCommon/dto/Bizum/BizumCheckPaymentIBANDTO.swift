//

import Foundation

public struct BizumCheckPaymentIBANDTO: Codable {
    
    public let country: String
    public let controlDigit: String
    public let codbban: String
    
    public init(country: String, controlDigit: String, codbban: String) {
        self.country = country
        self.controlDigit = controlDigit
        self.codbban = codbban
    }
    
    private enum CodingKeys: String, CodingKey {
        case country = "pais"
        case controlDigit = "digitodecontrol"
        case codbban
    }
    
    public var description: String {
        return (country + controlDigit + codbban).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
