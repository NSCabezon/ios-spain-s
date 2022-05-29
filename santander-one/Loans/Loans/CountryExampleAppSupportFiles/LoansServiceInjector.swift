import CoreTestData
import QuickSetup

public final class LoansServiceInjector: CustomServiceInjector {
    public init() {}
    public func inject(injector: MockDataInjector) {
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobalWithLoans"
        )
        injector.register(
            for: \.loansData.getLoanTransactions,
            filename: "LoanTransactionsListDTOMock"
        )
        injector.register(
            for: \.loansData.getLoanDetail,
            filename: "LoanDetailDTOMock"
        )
        injector.register(
            for: \.loansData.getLoanTransactionDetail,
            filename: "LoanTransactionDetailDTOMock"
        )
        injector.register(
            for: \.loansData.getLoanPartialAmortization,
            filename: "LoanPartialAmortizationDTOMock"
        )
        injector.register(
            for: \.loansData.validatePartialAmortization,
            filename: "LoanValidationDTOMock"
        )
        let appconfig = [
            "enableLoanRepayment": "true",
            "enableChangeLoanLinkedAccount": "true"
        ]
        injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            element: AppConfigDTOMock(defaultConfig: appconfig)
        )
    }
}
