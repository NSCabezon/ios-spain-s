//

import Foundation

public struct CardSettlementMovementDTO: Codable {
    public var operationDate: Date?
    public var operationHour: String?
    public var amount: Double?
    public var concept: String?
    public var settlementMov: String?
    
    private enum CodingKeys: String, CodingKey {
        case operationDate = "fechaOperacion"
        case operationHour = "horaOperacion"
        case amount = "importe"
        case concept = "concepto"
        case settlementMov = "movFinanciable"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let operationDateString = try? values.decode(String.self, forKey: .operationDate){
            self.operationDate = DateFormats.toDate(string: operationDateString, output: DateFormats.TimeFormat.YYYYMMDD)
        }
        operationHour = try values.decode(String.self, forKey: .operationHour)
        amount = try values.decode(Double.self, forKey: .amount)
        concept = try values.decode(String.self, forKey: .concept).trim()
        settlementMov = try values.decode(String.self, forKey: .settlementMov)
    }
}
