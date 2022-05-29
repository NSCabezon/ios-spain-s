public struct PensionTransactionsListDTO: Codable {
    public var transactionDTOs: [PensionTransactionDTO] = []
	public var pagination = PaginationDTO()
    
    public init() {}
    
    public init(transactionDTOs: [PensionTransactionDTO], pagination: PaginationDTO) {
        self.transactionDTOs = transactionDTOs
        self.pagination = pagination
    }
}
