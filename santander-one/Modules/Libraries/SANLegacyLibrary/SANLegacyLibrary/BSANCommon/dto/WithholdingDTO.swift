import Foundation

public struct WithholdingDTO: Codable {
    public let entryDate: Date
    public let leavingDate: Date
    public let concept: String
    public let amount: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case entryDate = "fechaAlta"
        case leavingDate = "fechaBaja"
        case concept = "concepto"
        case amount = "importe"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        entryDate = try values.decode(Date.self, forKey: .entryDate)
        leavingDate = try values.decode(Date.self, forKey: .leavingDate)
        concept = try values.decode(String.self, forKey: .concept)
        amount = try Decimal(string: values.decode(String.self, forKey: .amount)) ?? .zero
    }
    
    public init(entryDate: Date, leavingDate: Date, concept: String, amount: Decimal) {
        self.entryDate = entryDate
        self.leavingDate = leavingDate
        self.concept = concept
        self.amount = amount
    }
}
