public struct TransferListResponse {
    public var transactions: [TransferRepresentable]
    public var pagination: PaginationRepresentable?
    
    public init(transactions: [TransferRepresentable], pagination: PaginationRepresentable? = nil) {
        self.transactions = transactions
        self.pagination = pagination
    }
}
