import Foundation
import CoreFoundationLib
import CoreDomain

protocol LoadPfmSuperUseCaseDelegate: AnyObject {
    func finish(months: [MonthlyBalanceRepresentable])
    func informAccountFinished(account: AccountEntity)
    func informCardFinished(card: CardEntity)
}

class LoadPfmSuperUseCaseHelper {
    weak var delegate: LoadPfmSuperUseCaseDelegate?
    private let useCaseHandler: UseCaseHandler
    private let appConfigRepository: AppConfigRepositoryProtocol
    private var operations: [Int: Foundation.Operation & LoadPfmProtocol]
    private var totalRequests: Int
    private var pfmHelper: PfmHelper?
    private var cardsFinished: [CardEntity]
    private var accountsFinished: [AccountEntity]
    private var partialCards: [CardEntity: [CardTransactionEntity]]
    private var partialAccounts: [AccountEntity: [AccountTransactionEntity]]
    private var totalIndex: Int
    private let months: Int
    private let defaultBackwardDays: Int
    private let lockAccounts: DispatchSemaphore
    private let lockCards: DispatchSemaphore
    private let lockOperations: DispatchSemaphore
    private let lockTotalRequests: DispatchSemaphore
    private let lockTotalIndex: DispatchSemaphore
    private let lockPartialAccounts: DispatchSemaphore
    private let lockPartialCards: DispatchSemaphore
    private let maxPagination: Int
    private let dependenciesResolver: DependenciesResolver
    private var calculatePfmUseCase: CalculatePfmUseCase {
        return dependenciesResolver.resolve()
    }
    private var globalPositionUseCase: GetGlobalPositionUseCaseAlias {
        return dependenciesResolver.resolve()
    }
    private var getAllAccountTransactionsUseCase: GetAllAccountTransactionsUseCase {
        return dependenciesResolver.resolve()
    }
    private var getAllCardTransactionsUseCase: GetAllCardTransactionsUseCase {
        return dependenciesResolver.resolve()
    }
    private let appConfigCardTransactionsPFMDays = "cardTransactionsPFMDays"
    private let appConfigAccountTransactionsPFMDays = "accountTransactionsPFMDays"
    
    init(useCaseHandler: UseCaseHandler, appConfigRepository: AppConfigRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.useCaseHandler = useCaseHandler
        self.appConfigRepository = appConfigRepository
        self.operations = [:]
        self.partialCards = [:]
        self.partialAccounts = [:]
        self.totalIndex = 0
        self.totalRequests = 0
        self.cardsFinished = []
        self.accountsFinished = []
        self.months = 3
        self.defaultBackwardDays = 8
        self.lockAccounts = DispatchSemaphore(value: 1)
        self.lockCards = DispatchSemaphore(value: 1)
        self.lockOperations = DispatchSemaphore(value: 1)
        self.lockTotalIndex = DispatchSemaphore(value: 1)
        self.lockTotalRequests = DispatchSemaphore(value: 1)
        self.lockPartialAccounts = DispatchSemaphore(value: 1)
        self.lockPartialCards = DispatchSemaphore(value: 1)
        self.maxPagination = 25
        self.dependenciesResolver = dependenciesResolver
    }
    
    func execute(accounts: [AccountEntity], cards: [CardEntity], userId: String) {
        pfmHelper = PfmHelper(userId: userId)
        DispatchQueue.global(qos: .background).async {
            if cards.isEmpty && accounts.isEmpty {
                self.lockTotalRequests.wait()
                self.totalRequests = 1
                self.lockTotalRequests.signal()
                self.reduceAndCheckFinish()
            } else {
                self.getCards(cards: cards)
                self.getAccounts(accounts: accounts)
            }
        }
    }
    
    func isEndCard(card: CardEntity) -> Bool {
        return cardsFinished.contains(card)
    }
    
    func unreadCountForCard(card: CardEntity) -> Int {
        guard isEndCard(card: card), let result = pfmHelper?.getCountUnreadCardMovements(card: card) else {
            return 0
        }
        return result
    }
    
    func unreadCountForAccount(account: AccountEntity) -> Int {
        guard isEndAccount(account: account), let result = pfmHelper?.getCountUnreadAccountMovements(account: account) else {
            return 0
        }
        return result
    }
        
    func isEndAccount(byIBANPapel ibanPapel: String) -> Bool {
        return accountsFinished.contains {
            $0.getIBANPapel() == ibanPapel
        }
    }
    
    func isEndAccount(account: AccountEntity) -> Bool {
        return accountsFinished.contains(account)
    }
    
    private func getAccounts(accounts: [AccountEntity]) {
        pfmHelper?.insertAccounts(accounts: accounts)
        lockTotalRequests.wait()
        totalRequests += accounts.count
        lockTotalRequests.signal()
        for account in accounts {
            lockTotalIndex.wait()
            let index = totalIndex
            totalIndex += 1
            lockTotalIndex.signal()
            executeAccounts(account: account, pagination: nil, index: index, page: 0)
        }
    }
    
    func errorAccount(operation: LoadAccountsOperation, error: GetAllAccountTransactionsUseCaseErrorOutput, account: AccountEntity) {
        lockOperations.wait()
        operations[operation.referenceId] = nil
        lockOperations.signal()
        lockPartialAccounts.wait()
        partialAccounts[account] = nil
        lockPartialAccounts.signal()
        informAccountFinished(account: account)
        reduceAndCheckFinish()
    }
    
    func successAccount(operation: LoadAccountsOperation, response: GetAllAccountTransactionsUseCaseOkOutput, account: AccountEntity) {
        lockOperations.wait()
        operations[operation.referenceId] = nil
        lockOperations.signal()
        lockPartialAccounts.wait()
        var transactions = partialAccounts[account] ?? []
        lockPartialAccounts.signal()
        transactions.append(contentsOf: response.accountTransactions.transactions ?? [])
        if let pagination = response.accountTransactions.pagination, !pagination.isEnd, operation.page < maxPagination {
            lockPartialAccounts.wait()
            partialAccounts[account] = transactions
            lockPartialAccounts.signal()
            lockTotalRequests.wait()
            totalRequests += 1
            lockTotalRequests.signal()
            lockTotalIndex.wait()
            let index = totalIndex
            totalIndex += 1
            lockTotalIndex.signal()
            executeAccounts(account: account, pagination: pagination, index: index, page: operation.page + 1)
        } else {
            lockPartialAccounts.wait()
            partialAccounts[account] = nil
            lockPartialAccounts.signal()
            pfmHelper?.insertAccountMovements(account: account, transactions: transactions)
            informAccountFinished(account: account)
        }
        reduceAndCheckFinish()
    }
    
    private func getCards(cards: [CardEntity]) {
        pfmHelper?.insertCards(cards: cards)
        lockTotalRequests.wait()
        totalRequests += cards.count
        lockTotalRequests.signal()
        for card in cards {
            lockTotalIndex.wait()
            let index = totalIndex
            totalIndex += 1
            lockTotalIndex.signal()
            executeCards(card: card, pagination: nil, index: index, page: 0)
        }
    }
    
    func errorCard(operation: LoadCardsOperation, error: GetAllCardTransactionsUseCaseErrorOutput, card: CardEntity) {
        lockOperations.wait()
        operations[operation.referenceId] = nil
        lockOperations.signal()
        lockPartialCards.wait()
        partialCards[card] = nil
        lockPartialCards.signal()
        informCardFinished(card: card)
        reduceAndCheckFinish()
    }
    
    func successCard(operation: LoadCardsOperation, response: GetAllCardTransactionsUseCaseOkOutput, card: CardEntity) {
        lockOperations.wait()
        operations[operation.referenceId] = nil
        lockOperations.signal()
        lockPartialCards.wait()
        var transactions = partialCards[card] ?? []
        lockPartialCards.signal()
        transactions.append(contentsOf: response.transaction)
        if let pagination = response.pagination, !pagination.isEnd, operation.page < maxPagination {
            lockPartialCards.wait()
            partialCards[card] = transactions
            lockPartialCards.signal()
            lockTotalRequests.wait()
            totalRequests += 1
            lockTotalRequests.signal()
            lockTotalIndex.wait()
            let index = totalIndex
            totalIndex += 1
            lockTotalIndex.signal()
            executeCards(card: card, pagination: pagination, index: index, page: operation.page + 1)
        } else {
            lockPartialCards.wait()
            partialCards[card] = nil
            lockPartialCards.signal()
            pfmHelper?.insertCardMovements(card: card, transactions: transactions)
            informCardFinished(card: card)
        }
        reduceAndCheckFinish()
    }
    
    func cancelAll () {
        lockOperations.wait()
        operations.values.forEach {
            $0.cancel()
        }
        lockOperations.signal()
    }
    
    private func getBackwardDays(key: String) -> Int {
        guard let days: String = appConfigRepository.getString(key), let backwardDays = Int(days) else {
            return defaultBackwardDays
        }
        return backwardDays
    }
    
    private func executeCards(card: CardEntity, pagination: PaginationEntity?, index: Int, page: Int) {
        let days = getBackwardDays(key: appConfigCardTransactionsPFMDays)
        guard let lastDateCard = pfmHelper?.getLastDateForCard(card: card, backwardDays: days) else { return }
        let dateFilter = DateFilterEntity.fromOtherDateToCurrentDate(fromDate: lastDateCard)
        let input = GetAllCardTransactionsUseCaseInput(card: card, dateFilter: dateFilter, pagination: pagination)
        let usecase = getAllCardTransactionsUseCase
        _ = usecase.setRequestValues(requestValues: input)
        let operation = LoadCardsOperation(self, useCase: usecase, referenceId: index, card: card, page: page)
        operation.queuePriority = Operation.QueuePriority.low
        lockOperations.wait()
        operations[index] = operation
        lockOperations.signal()
        useCaseHandler.execute(operation)
    }
    
    private func executeAccounts(account: AccountEntity, pagination: PaginationEntity?, index: Int, page: Int) {
        let days = getBackwardDays(key: appConfigAccountTransactionsPFMDays)
        guard let lastDateAccount = pfmHelper?.getLastDateForAccount(account: account, backwardDays: days) else { return }
        let dateFilter = DateFilterEntity.fromOtherDateToCurrentDate(fromDate: lastDateAccount)
        let input = GetAllAccountTransactionsUseCaseInput(account: account, dateFilter: dateFilter, pagination: pagination)
        let usecase = getAllAccountTransactionsUseCase
        _ = usecase.setRequestValues(requestValues: input)
        let operation = LoadAccountsOperation(self, useCase: usecase, referenceId: index, account: account, page: page)
        operation.queuePriority = Operation.QueuePriority.low
        lockOperations.wait()
        operations[index] = operation
        lockOperations.signal()
        useCaseHandler.execute(operation)
    }
    
    private func reduceAndCheckFinish () {
        lockTotalRequests.wait()
        totalRequests -= 1
        if totalRequests == 0 {
            lockTotalRequests.signal()
            lockAccounts.wait()
            lockCards.wait()
            lockAccounts.signal()
            lockCards.signal()
            getPfm()
        } else {
            lockTotalRequests.signal()
        }
    }
    
    func getPfm() {
        guard let pfmHelper = pfmHelper else {
            finish(months: [])
            return
        }
        
        Scenario(useCase: globalPositionUseCase)
            .execute(on: DispatchQueue.main)
            .then { [months, calculatePfmUseCase] result -> Scenario<CalculatePfmUseCaseInput, CalculatePfmUseCaseOkOutput, StringErrorOutput> in
                let input = CalculatePfmUseCaseInput(accounts: result.globalPosition.accounts.visibles(), months: months, pfmHelper: pfmHelper)
                return Scenario(useCase: calculatePfmUseCase, input: input)
            }
            .onSuccess { [weak self] result in
                self?.finish(months: result.monthsPfm)
            }
            .onError { [weak self] _ in
                self? .finish(months: [])
            }
    }
    
    private func informCardFinished(card: CardEntity) {
        lockCards.wait()
        cardsFinished.append(card)
        lockCards.signal()
        delegate?.informCardFinished(card: card)
    }
    
    private func informAccountFinished(account: AccountEntity) {
        lockAccounts.wait()
        accountsFinished.append(account)
        lockAccounts.signal()
        delegate?.informAccountFinished(account: account)
    }
    
    private func finish(months: [MonthlyBalanceRepresentable]) {
        cardsFinished.removeAll()
        accountsFinished.removeAll()
        delegate?.finish(months: months)
    }
}
