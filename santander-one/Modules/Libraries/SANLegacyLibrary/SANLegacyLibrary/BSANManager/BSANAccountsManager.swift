import CoreDomain

public protocol BSANAccountsManager {
    func getAllAccounts() throws -> BSANResponse<[AccountDTO]>
    func getAccountDetail(forAccount account: AccountDTO) throws -> BSANResponse<AccountDetailDTO>
    func getAllAccountTransactions(forAccount account: AccountDTO, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO>
    func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO>
    func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<AccountTransactionsListDTO>
    func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO>
    func getAccountTransactionDetail(from transactionDTO: AccountTransactionDTO) throws -> BSANResponse<AccountTransactionDetailDTO>
    func checkAccountMovementPdf(accountDTO: AccountDTO, accountTransactionDTO: AccountTransactionDTO) throws -> BSANResponse<DocumentDTO>
    func getAccount(fromOldContract oldContract: ContractDTO?) throws -> BSANResponse<AccountDTO>
    func getAccount(fromIBAN iban: IBANDTO?) throws -> BSANResponse<AccountDTO>
    func getAccountEasyPay() throws -> BSANResponse<[AccountEasyPayDTO]>
    func changeAccountAlias(accountDTO: AccountDTO, newAlias: String) throws -> BSANResponse<Void>
    func changeMainAccount(accountDTO: AccountDTO, newMain: Bool) throws -> BSANResponse<Void>
    func getWithholdingList(iban: String, currency: String) throws -> BSANResponse<WithholdingListDTO>
    func getAccountMovements(params: AccountMovementListParams, account: String) throws -> BSANResponse<AccountMovementListDTO>
    func getAccountFutureBills(params: AccountFutureBillParams) throws -> BSANResponse<AccountFutureBillListDTO>
    func getAccountTransactionCategory(params: TransactionCategorizerInputParams) throws -> BSANResponse<TransactionCategorizerDTO>
}
