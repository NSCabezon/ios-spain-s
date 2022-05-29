import Foundation
import CoreFoundationLib
import SANLibraryV3

public class WidgetAccountTransactionsUseCase: UseCase<WidgetAccountTransactionsUseCaseInput, WidgetAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    
    public init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
        super.init()
    }
    
    public override func executeUseCase(requestValues: WidgetAccountTransactionsUseCaseInput) throws -> UseCaseResponse<WidgetAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        let accountsManager = bsanManagersProvider.getBsanAccountsManager()
        let dto = requestValues.account.accountDTO
        let response = try accountsManager.getAccountTransactions(forAccount: dto, pagination: nil, dateFilter: nil)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let list = try response.getResponseData()
        let accountTransactions = list?.transactionDTOs.map { AccountTransaction(accountTransactionDTO: $0) }
        return UseCaseResponse.ok(WidgetAccountTransactionsUseCaseOkOutput(accountTransactions: accountTransactions ?? []))
    }
}

public struct WidgetAccountTransactionsUseCaseInput {
    let account: Account
}

public struct WidgetAccountTransactionsUseCaseOkOutput {
    let accountTransactions: [AccountTransaction]
}
