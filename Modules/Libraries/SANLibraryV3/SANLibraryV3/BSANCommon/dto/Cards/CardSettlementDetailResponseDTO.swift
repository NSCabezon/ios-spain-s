//

public struct CardSettlementDetailResponseDTO: Decodable {
    public var settlementDetails: [CardSettlementDetailDTO]?
    public var errorCode: CardSettlementEmptyDetailDTO?
    public var statusCode: Int?
    
    public init(from decoder: Decoder) throws {
        do {
            self.settlementDetails = try decoder.singleValueContainer().decode([CardSettlementDetailDTO].self)
        } catch {
            self.errorCode = try? decoder.singleValueContainer().decode(CardSettlementEmptyDetailDTO.self)
            self.statusCode = try? decoder.singleValueContainer().decode(Int.self)
        }
    }
}
