import SwiftyJSON

public struct FinanceableMovementsListDTO: Codable {
    public var movements: [FinanceableMovementDTO]?
    
    public init(json: JSON) {
        self.movements = json["movements"].array?.map({ FinanceableMovementDTO(json: $0) }) ?? []
    }
}
