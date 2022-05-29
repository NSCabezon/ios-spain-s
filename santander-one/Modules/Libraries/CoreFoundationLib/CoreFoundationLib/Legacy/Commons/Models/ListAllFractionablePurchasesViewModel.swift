import SANLegacyLibrary

public struct ListAllFractionablePurchasesByDayViewModel {
    let dayMovements: [FractionablePurchaseViewModel]
    let date: Date
    let dependenciesResolver: DependenciesResolver
    
    public init(_ movements: [FractionablePurchaseViewModel],
                date: Date,
                dependenciesResolver: DependenciesResolver) {
        self.dayMovements = movements
        self.date = date
        self.dependenciesResolver = dependenciesResolver
    }
    
    public func getDayMovements() -> [FractionablePurchaseViewModel] {
        dayMovements
    }
    
    public func getDate() -> Date {
        date
    }
    
    public var dateFormatted: LocalizedStylableText {
        let dateString = dependenciesResolver.resolve(for: TimeManager.self)
            .toStringFromCurrentLocale(date: date, outputFormat: .d_MMM_eeee)?.uppercased() ?? ""
        return localized(dateString)
    }
    
    public func setDateFormatterFiltered(_ filtered: Bool) -> LocalizedStylableText {
        let decorator = DateDecorator(self.date)
        return decorator.setDateFormatter(filtered)
    }
}

public struct FractionablePurchaseViewModel {
    let cardEntity: CardEntity
    var financeableMovementEntity: FinanceableMovementEntity
    let timeManager: TimeManager

    public init(cardEntity: CardEntity,
                financeableMovementEntity: FinanceableMovementEntity,
                timeManager: TimeManager) {
        self.cardEntity = cardEntity
        self.financeableMovementEntity = financeableMovementEntity
        self.timeManager = timeManager
    }
    
    public func getCardEntity() -> CardEntity {
        cardEntity
    }
    
    public func getFinanceableMovementEntity() -> FinanceableMovementEntity {
        financeableMovementEntity
    }
    
    public mutating func setMovementAssociatedCard(_ card: CardEntity) {
        financeableMovementEntity.setAssociatedCard(card)
    }

    public mutating func setMovementExpanded(_ value: Bool) {
        financeableMovementEntity.setIsExpanded(value)
    }

    public func getIsExpanded() -> Bool { financeableMovementEntity.getIsExpanded() }
    
    public func getMovementAssociatedCard() -> CardEntity? { financeableMovementEntity.getAssociatedCard() }

    public func getMovementTransaction() -> CardListFinanceableTransactionViewModel? { financeableMovementEntity.getAssociatedTransaction() }

    public mutating func setMovementTransaction(_ transaction: CardListFinanceableTransactionViewModel) {
        financeableMovementEntity.setAssociatedTransacion(transaction)
    }
    
    public var identifier: String? {
        guard let date = financeableMovementEntity.operationDate,
              let movDay = financeableMovementEntity.transactionDay else {
                  return nil
              }
        return date + "_" + movDay
    }

    public var movementTitle: String? {
        financeableMovementEntity.name
    }
    public var amount: AmountEntity? {
        financeableMovementEntity.amount
    }
    public var imageUrl: String? {
        cardEntity.cardImageUrl()
    }
    public var pan: String? {
        cardEntity.pan
    }
    public var cardName: String? {
        cardEntity.alias
    }
    public var isExpanded: Bool = false
    public var date: Date {
        financeableMovementEntity.date ?? Date()
    }
    public var cardTitle: String {
        return (cardName ?? "") + " | *" + (pan?.substring(ofLast: 4) ?? "")
    }
    
    public var transaction: CardListFinanceableTransactionViewModel?
    
    public var cardTransaction: CardTransactionEntity {
        var tempDTO = CardTransactionDTO()
        tempDTO.operationDate = timeManager.fromString(input: financeableMovementEntity.operationDate, inputFormat: .yyyyMMdd)
        tempDTO.amount = financeableMovementEntity.amountDTO
        tempDTO.description = financeableMovementEntity.description
        tempDTO.balanceCode = financeableMovementEntity.balanceCode
        tempDTO.annotationDate = timeManager.fromString(input: financeableMovementEntity.liquidationDate, inputFormat: .yyyyMMdd)
        tempDTO.transactionDay = financeableMovementEntity.transactionDay
        tempDTO.originalCurrency = financeableMovementEntity.originalCurrency
        if let date = financeableMovementEntity.operationDate, let movDay = tempDTO.transactionDay {
            tempDTO.identifier = date + "_" + movDay
        }
        return CardTransactionEntity(tempDTO)
    }
}
