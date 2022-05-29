import SANLegacyLibrary

public struct FinanceableMovementEntity {

    public let dto: FinanceableMovementDTO
    public var identifier: String? { dto.movementId }
    public var date: Date?
    public var name: String? { dto.description }
    public var operationDate: String? { dto.operationDate }
    public var transactionDay: String? { dto.transactionDay }
    public var amountDTO: AmountDTO? { dto.amount }
    public var description: String? { dto.description }
    public var balanceCode: String? { dto.balanceCode }
    public var liquidationDate: String? { dto.liquidationDate }
    public var originalCurrency: CurrencyDTO? { dto.originalCurrency }
    public var amount: AmountEntity? {
        guard let amountDTO = dto.amount else { return nil }
        return AmountEntity(amountDTO)
    }
    
    public var pendingFees: Int { dto.status?.pendingQuotas ?? 0 }
    
    public var totalFees: Int {
        let paidQuotas = dto.status?.paidQuotas ?? 0
        let pendingQuotas = dto.status?.pendingQuotas ?? 0
        return paidQuotas + pendingQuotas
    }
    
    public var status: EasyPayStatusCode {
        dto.status?.statusCode ?? .cancelled
    }
    
    private var associatedCard: CardEntity?
    private var transaction: CardListFinanceableTransactionViewModel?
    private var isExpanded: Bool = false
    
    public init(dto: FinanceableMovementDTO, date: Date?) {
        self.dto = dto
        self.date = date
    }
    
    public mutating func setAssociatedCard(_ card: CardEntity) {
        self.associatedCard = card
    }
    
    public func getAssociatedCard() -> CardEntity? { associatedCard }
    
    public mutating func setIsExpanded(_ value: Bool) {
        self.isExpanded = value
    }
    
    public func getIsExpanded() -> Bool { isExpanded }
    
    public mutating func setAssociatedTransacion(_ transaction: CardListFinanceableTransactionViewModel) {
        self.transaction = transaction
    }
    
    public func getAssociatedTransaction() -> CardListFinanceableTransactionViewModel? { transaction }
    
}
