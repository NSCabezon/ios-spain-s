import SANLegacyLibrary

public class MockLoansDataProvider {
    public var getLoanTransactions: LoanTransactionsListDTO!
    public var getLoanDetail: LoanDetailDTO!
    public var getLoanTransactionDetail: LoanTransactionDetailDTO!
    public var getLoanPartialAmortization: LoanPartialAmortizationDTO!
    public var validatePartialAmortization: LoanValidationDTO!
}
