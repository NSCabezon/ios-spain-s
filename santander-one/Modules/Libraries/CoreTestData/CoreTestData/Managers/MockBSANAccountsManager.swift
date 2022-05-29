import SANLegacyLibrary
import CoreDomain

public struct MockBSANAccountsManager: BSANAccountsManager {
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    public func getAllAccounts() throws -> BSANResponse<[AccountDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAllAccountsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountDetail(forAccount account: AccountDTO) throws -> BSANResponse<AccountDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountDetailMock
        return BSANOkResponse(dto)
    }
    
    public func getAllAccountTransactions(forAccount account: AccountDTO, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAllAccountTransactionsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?) throws -> BSANResponse<AccountTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountTransactionsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, dateFilter: DateFilter?, cached: Bool) throws -> BSANResponse<AccountTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountTransactionsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountTransactions(forAccount account: AccountDTO, pagination: PaginationDTO?, filter: AccountTransferFilterInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountTransactionsWithFilterMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountTransactionDetail(from transactionDTO: AccountTransactionDTO) throws -> BSANResponse<AccountTransactionDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountTransactionDetailMock
        return BSANOkResponse(dto)
    }
    
    public func checkAccountMovementPdf(accountDTO: AccountDTO, accountTransactionDTO: AccountTransactionDTO) throws -> BSANResponse<DocumentDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.checkAccountMovementPdfMock
        return BSANOkResponse(dto)
    }
    
    public func getAccount(fromOldContract oldContract: ContractDTO?) throws -> BSANResponse<AccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountFromOldContractMock
        return BSANOkResponse(dto)
    }
    
    public func getAccount(fromIBAN iban: IBANDTO?) throws -> BSANResponse<AccountDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountFromIbanMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountEasyPay() throws -> BSANResponse<[AccountEasyPayDTO]> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountEasyPayMock
        return BSANOkResponse(dto)
    }
    
    public func changeAccountAlias(accountDTO: AccountDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    public func changeMainAccount(accountDTO: AccountDTO, newMain: Bool) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    public func getWithholdingList(iban: String, currency: String) throws -> BSANResponse<WithholdingListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getWithholdingListMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountMovements(params: AccountMovementListParams, account: String) throws -> BSANResponse<AccountMovementListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountMovementsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountFutureBills(params: AccountFutureBillParams) throws -> BSANResponse<AccountFutureBillListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountFutureBillsMock
        return BSANOkResponse(dto)
    }
    
    public func getAccountTransactionCategory(params: TransactionCategorizerInputParams) throws -> BSANResponse<TransactionCategorizerDTO> {
        let dto = self.mockDataInjector.mockDataProvider.accountData.getAccountTransactionCategoryMock
        return BSANOkResponse(dto)
    }
}
