import SANLegacyLibrary
public struct CardSettlementDetailsInfo: Codable {
    private var cardSettlementDetailCache: [String: CardSettlementDetailDTO] = [:]
    
    // MARK: - Handle Cache for current CardSettlementDetail DTO
    public func setCardSettlementDetailsCacheFor(_ key: String) -> CardSettlementDetailDTO? {
        cardSettlementDetailCache[key]
    }
    
    public mutating func addCardSettlementDetailsCache(_ key: String, cardSettlementDetailDTO: CardSettlementDetailDTO) {
        cardSettlementDetailCache[key] = cardSettlementDetailDTO
    }
}

public enum MovementStatus {
    case fractionable
    case others
}

public struct FinanceableCardMovementsInfo: Codable {
    private var financeableCardMovementsCache: [String: FinanceableMovementsListDTO] = [:]
    private var noFinanceableCardMovementsCache: [String: FinanceableMovementsListDTO] = [:]
    
    // MARK: - Handle Cache for current FinanceableMovementsList DTO
    public func getFinanceableCardMovementsCacheFor(_ key: String, status: MovementStatus) -> FinanceableMovementsListDTO? {
        switch status {
        case .fractionable:
            return financeableCardMovementsCache[key]
        case .others:
            return noFinanceableCardMovementsCache[key]
        }
    }
    
    public mutating func addFinanceableCardMovementsCache(_ key: String, financeableList: FinanceableMovementsListDTO, status: MovementStatus) {
        switch status {
        case .fractionable:
            return financeableCardMovementsCache[key] = financeableList
        case .others:
            return noFinanceableCardMovementsCache[key] = financeableList
        }
    }
}
