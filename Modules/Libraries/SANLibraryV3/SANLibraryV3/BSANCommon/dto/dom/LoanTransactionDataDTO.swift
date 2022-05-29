public struct LoanTransactionDataDTO: Codable {
    public var bankOperation: BankOperationDTO?
    public var dgoNumber: DGONumberDTO?
    public var impAmount: AmountDTO?
    public var transactionNumber: String?
    public var loanDatesDTO: LoanDatesDTO?
}
