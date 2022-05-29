import CoreFoundationLib
import SANLibraryV3

class QuickBalanceTransactionsUseCase: UseCase<QuickBalanceTransactionsUseCaseInput, QuickBalanceTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: QuickBalanceTransactionsUseCaseInput) throws -> UseCaseResponse<QuickBalanceTransactionsUseCaseOkOutput, StringErrorOutput> {
        let bsanManagersProvider: BSANManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let accountsManager = bsanManagersProvider.getBsanAccountsManager()
        let dto = requestValues.account.dto
        let response = try accountsManager.getAccountTransactions(forAccount: dto, pagination: nil, dateFilter: nil)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let list = try response.getResponseData()
        let accountTransactions = list?.transactionDTOs.map {
            AccountTransactionWithAccountEntity(accountTransactionEntity: AccountTransactionEntity($0), accountEntity: AccountEntity(dto))
        }
        return UseCaseResponse.ok(QuickBalanceTransactionsUseCaseOkOutput(accountTransactions: accountTransactions ?? []))
    }
}

struct QuickBalanceTransactionsUseCaseInput {
    let account: AccountEntity
}

struct QuickBalanceTransactionsUseCaseOkOutput {
    let accountTransactions: [AccountTransactionWithAccountEntity]
}
