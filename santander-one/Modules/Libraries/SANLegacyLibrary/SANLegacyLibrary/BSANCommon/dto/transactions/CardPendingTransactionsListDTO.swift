public struct CardPendingTransactionsListDTO: Codable {
    public var cardPendingTransactionDTOS: [CardPendingTransactionDTO]?
    public var pagination: PaginationDTO?
    
    public init() {}
    
    public init(cardPendingTransactionDTOS: [CardPendingTransactionDTO]?, pagination: PaginationDTO?){
        self.cardPendingTransactionDTOS = cardPendingTransactionDTOS
        self.pagination = pagination
    }
}
