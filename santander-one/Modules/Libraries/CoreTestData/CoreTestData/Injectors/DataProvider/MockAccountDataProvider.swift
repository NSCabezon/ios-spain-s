import SANLegacyLibrary

public class MockAccountDataProvider {
    public var getAllAccountsMock: [AccountDTO]!
    public var getAccountDetailMock: AccountDetailDTO!
    public var getAllAccountTransactionsMock: AccountTransactionsListDTO!
    public var getAccountTransactionsMock: AccountTransactionsListDTO!
    public var getAccountTransactionsWithFilterMock: AccountTransactionsListDTO!
    public var getAccountTransactionDetailMock: AccountTransactionDetailDTO!
    public var checkAccountMovementPdfMock: DocumentDTO!
    public var getAccountFromOldContractMock: AccountDTO!
    public var getAccountFromIbanMock: AccountDTO!
    public var getAccountEasyPayMock: [AccountEasyPayDTO]!
    public var getWithholdingListMock: WithholdingListDTO!
    public var getAccountMovementsMock: AccountMovementListDTO!
    public var getAccountFutureBillsMock: AccountFutureBillListDTO!
    public var getAccountTransactionCategoryMock: TransactionCategorizerDTO!
}
