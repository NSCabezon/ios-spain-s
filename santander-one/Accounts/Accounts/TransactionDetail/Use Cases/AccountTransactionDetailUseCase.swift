import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class AccountTransactionDetailUseCase: UseCase<AccountTransactionDetailUseCaseInput, AccountTransactionDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: AccountTransactionDetailUseCaseInput) throws -> UseCaseResponse<AccountTransactionDetailUseCaseOkOutput, StringErrorOutput> {
        let accountsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanAccountsManager()
       
        let response = try accountsManager.getAccountTransactionDetail(from: requestValues.transaction.dto)
       
        guard response.isSuccess(), let detail = try response.getResponseData() else {
            return .error(StringErrorOutput("transaction_label_emptyError"))
        }
        return .ok(AccountTransactionDetailUseCaseOkOutput(detail: AccountTransactionDetailEntity(detail)))
    }
}

struct AccountTransactionDetailUseCaseInput {
    let transaction: AccountTransactionEntity
    let account: AccountEntity
}

struct AccountTransactionDetailUseCaseOkOutput {
    let detail: AccountTransactionDetailEntity
}
