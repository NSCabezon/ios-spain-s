import Foundation
import CoreFoundationLib

protocol WidgetAccountsTransactionsSuperUseCaseDelegate: class {
    func finish(accountTransactions: [AccountTransaction])
}

protocol WidgetAccountsTransactionsSuperUseCaseProtocol: class {
    func getAccounts(accounts: [Account])
}

class WidgetAccountsTransactionsSuperUseCase {
    private var partialAccountsTransactions: ThreadSafeProperty<[AccountTransaction]> = ThreadSafeProperty([])
    private var totalRequests = ThreadSafeProperty(0)
    private var operations: ThreadSafeProperty<[Int: Operation & LoadAccountTransactionProtocol]> = ThreadSafeProperty([:])
    private weak var delegate: WidgetAccountsTransactionsSuperUseCaseDelegate?
    private let useCaseHandler: UseCaseHandler
    
    init(delegate: WidgetAccountsTransactionsSuperUseCaseDelegate, useCaseHandler: UseCaseHandler) {
        self.delegate = delegate
        self.useCaseHandler = useCaseHandler
    }
    
    func errorTransactions(operation: LoadAccountTransactionsOperation) {
        operations.value[operation.referenceId] = nil
        reduceAndCheckFinish()
    }
    
    func reciveTransactions(operation: LoadAccountTransactionsOperation, response: WidgetAccountTransactionsUseCaseOkOutput) {
        operations.value[operation.referenceId] = nil
        partialAccountsTransactions.value.append(contentsOf: response.accountTransactions)
        reduceAndCheckFinish()
    }
    
    private func executeAccount(account: Account, index: Int) {
        let input = WidgetAccountTransactionsUseCaseInput(account: account)
        let usecase = WidgetDependencies.accountTransactionsUseCase(input: input)
        let operation = LoadAccountTransactionsOperation(self, useCase: usecase, referenceId: index)
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
            let result =  partialAccountsTransactions.value.sorted(by: {$0.operationDate ?? Date() > $1.operationDate ?? Date()})
            DispatchQueue.main.async {
                self.delegate?.finish(accountTransactions: result)
            }
        }
    }
}

extension WidgetAccountsTransactionsSuperUseCase: WidgetAccountsTransactionsSuperUseCaseProtocol {
    func getAccounts(accounts: [Account]) {
        cancelAll()
        if accounts.count > 0 {
            totalRequests.value = accounts.count
            for i in 0..<accounts.count {
                let account = accounts[i]
                executeAccount(account: account, index: i)
            }
        } else {
            delegate?.finish(accountTransactions: [])
        }
    }
}

