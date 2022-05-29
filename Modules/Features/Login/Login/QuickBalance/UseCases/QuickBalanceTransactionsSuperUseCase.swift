import CoreFoundationLib
import SANLibraryV3
import Foundation

protocol QuickBalanceTransactionsSuperUseCaseDelegate: class {
    func finish(accountTransactions: [AccountTransactionWithAccountEntity])
}

protocol QuickBalanceTransactionsSuperUseCaseProtocol: class {
    func getAccounts(accounts: [AccountEntity])
}

class QuickBalanceTransactionsSuperUseCase {
    private var partialAccountsTransactions: ThreadSafeProperty<[AccountTransactionWithAccountEntity]> = ThreadSafeProperty([])
    private var totalRequests = ThreadSafeProperty(0)
    private var operations: ThreadSafeProperty<[Int: Foundation.Operation & QuickBalanceTransactionOperationProtocol]> = ThreadSafeProperty([:])
    private weak var delegate: QuickBalanceTransactionsSuperUseCaseDelegate?
    private let useCaseHandler: UseCaseHandler
    private let dependenciesResolver: DependenciesResolver
    
    init(delegate: QuickBalanceTransactionsSuperUseCaseDelegate, useCaseHandler: UseCaseHandler, dependenciesResolver: DependenciesResolver) {
        self.delegate = delegate
        self.useCaseHandler = useCaseHandler
        self.dependenciesResolver = dependenciesResolver
    }
    
    func errorTransactions(operation: QuickBalanceTransactionsOperation) {
        operations.value[operation.referenceId] = nil
        reduceAndCheckFinish()
    }
    
    func reciveTransactions(operation: QuickBalanceTransactionsOperation, response: QuickBalanceTransactionsUseCaseOkOutput) {
        operations.value[operation.referenceId] = nil
        partialAccountsTransactions.value.append(contentsOf: response.accountTransactions)
        reduceAndCheckFinish()
    }
    
    private func executeAccount(account: AccountEntity, index: Int) {
        let input = QuickBalanceTransactionsUseCaseInput(account: account)
        let usecase = QuickBalanceTransactionsUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
        let operation = QuickBalanceTransactionsOperation(self, useCase: usecase, referenceId: index)
        operations.value[index] = operation
        useCaseHandler.execute(operation)
    }
    
    private func cancelAll() {
        totalRequests.value = 0
        partialAccountsTransactions.value.removeAll()
        for operation in operations.value.values {
            operation.cancel()
        }
        operations.value.removeAll()
    }
    
    private func reduceAndCheckFinish () {
        totalRequests.value -= 1
        if totalRequests.value == 0 {
            let result =  partialAccountsTransactions.value.sorted(by: {$0.accountTransactionEntity.operationDate ?? Date() > $1.accountTransactionEntity.operationDate ?? Date()})
            DispatchQueue.main.async {
                self.delegate?.finish(accountTransactions: result)
            }
        }
    }
}

extension QuickBalanceTransactionsSuperUseCase: QuickBalanceTransactionsSuperUseCaseProtocol {
    func getAccounts(accounts: [AccountEntity]) {
        cancelAll()
        if accounts.count > 0 {
            totalRequests.value = accounts.count
            for index in 0..<accounts.count {
                let account = accounts[index]
                executeAccount(account: account, index: index)
            }
        } else {
            delegate?.finish(accountTransactions: [])
        }
    }
}
