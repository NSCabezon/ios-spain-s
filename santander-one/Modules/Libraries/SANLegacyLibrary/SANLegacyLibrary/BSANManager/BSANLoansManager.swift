import CoreDomain

public protocol BSANLoansManager {
    func getLoanTransactions(forLoan loan: LoanDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<LoanTransactionsListDTO>
    func getLoanDetail(forLoan loan: LoanDTO) throws -> BSANResponse<LoanDetailDTO>
    func getLoanTransactionDetail(forLoan loan: LoanDTO, loanTransaction: LoanTransactionDTO) throws -> BSANResponse<LoanTransactionDetailDTO>
    func removeLoanDetail(loanDTO: LoanDTO) throws -> BSANResponse<Void>
    func confirmChangeAccount(loanDTO: LoanDTO, accountDTO: AccountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func changeLoanAlias(_ loan: LoanDTO, newAlias: String) throws -> BSANResponse<Void>
}
