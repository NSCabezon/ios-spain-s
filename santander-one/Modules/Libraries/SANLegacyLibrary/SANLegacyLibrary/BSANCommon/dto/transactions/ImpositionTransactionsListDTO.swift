public struct ImpositionTransactionsListDTO: Codable {
    public var transactionDTOs: [ImpositionTransactionDTO]?
    public var pagination: PaginationDTO?

    public init() {}
}
