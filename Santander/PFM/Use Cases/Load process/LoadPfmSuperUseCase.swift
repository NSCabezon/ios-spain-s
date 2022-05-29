import Foundation
import CoreFoundationLib
import CoreDomain

protocol PfmController: AnyObject {
    var isFinish: Bool { get }
    func execute(accounts: [AccountEntity], cards: [CardEntity], userId: String)
    func unreadCountForCards(cards: [CardEntity]) -> Int
    func unreadCountForCard(card: CardEntity) -> Int
    func unreadCountForAccounts(accounts: [AccountEntity]) -> Int
    func unreadCountForAccount(account: AccountEntity) -> Int
    func isEndCard(card: CardEntity) -> Bool
    func isEndAccount(account: AccountEntity) -> Bool
    func subscribe(subscriber: PfmHelperSubscriber)
    func finishSession()
    func calculatePfm()
    func cancelAll()
}

protocol PfmHelperSubscriber: AnyObject {
    func pfmDidFinish(months: [MonthlyBalanceRepresentable])
    func pfmEndCard(card: CardEntity)
    func pfmEndAccount(account: AccountEntity)
}

extension PfmHelperSubscriber {
    func pfmDidFinish(months: [MonthlyBalanceRepresentable]) {}
    func pfmEndCard(card: CardEntity) {}
    func pfmEndAccount(account: AccountEntity) {}
}

class LoadPfmSuperUseCase: PfmController {
    private let useCaseHandler: UseCaseHandler
    private let appConfigRepository: AppConfigRepositoryProtocol
    private var helper: LoadPfmSuperUseCaseHelper?
    private var subscribers: [WeakReference<PfmHelperSubscriber>]
    private var moduleSubscribers: [WeakReference<PfmControllerSubscriber>]
    var isFinish: Bool
    private let compilation: CompilationProtocol
    private var pfmMonthsHistory: [MonthlyBalanceRepresentable]?
    private let dependenciesResolver: DependenciesResolver
    private var globalPositionUseCase: GetGlobalPositionUseCaseAlias {
        return dependenciesResolver.resolve()
    }
    private var handler: PFMTransactionsHandler {
        return dependenciesResolver.resolve()
    }
    
    init(useCaseHandler: UseCaseHandler, appConfigRepository: AppConfigRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.useCaseHandler = useCaseHandler
        self.appConfigRepository = appConfigRepository
        self.subscribers = []
        self.moduleSubscribers = []
        self.isFinish = false
        self.compilation = dependenciesResolver.resolve(for: CompilationProtocol.self)
        self.dependenciesResolver = dependenciesResolver
    }
    
    func execute(accounts: [AccountEntity], cards: [CardEntity], userId: String) {
        cancelAll()
        helper = LoadPfmSuperUseCaseHelper(useCaseHandler: useCaseHandler, appConfigRepository: appConfigRepository, dependenciesResolver: dependenciesResolver)
        helper?.delegate = self
        helper?.execute(accounts: accounts, cards: cards, userId: userId)
    }
    
    func subscribe(subscriber: PfmHelperSubscriber) {
        let unretainedSubscriber = WeakReference<PfmHelperSubscriber>(reference: subscriber)
        subscribers.append(unretainedSubscriber)
    }
    
    func isEndCard(card: CardEntity) -> Bool {
        return isFinish || helper?.isEndCard(card: card) ?? false
    }
    
    func unreadCountForCards(cards: [CardEntity]) -> Int {
        return cards.reduce(into: 0, { (result, card) in
            result += unreadCountForCard(card: card)
        })
    }
    
    func unreadCountForCard(card: CardEntity) -> Int {
        guard isEndCard(card: card), let result = helper?.unreadCountForCard(card: card) else {
            return 0
        }
        return result
    }
    
    func unreadCountForAccounts(accounts: [AccountEntity]) -> Int {
        return accounts.reduce(into: 0, { (result, account) in
            result += unreadCountForAccount(account: account)
        })
    }
    
    func unreadCountForAccount(account: AccountEntity) -> Int {
        guard isEndAccount(account: account), let result = helper?.unreadCountForAccount(account: account) else {
            return 0
        }
        return result
    }
    
    func isEndAccount(account: AccountEntity) -> Bool {
        return isFinish || helper?.isEndAccount(account: account) ?? false
    }
    
    func cancelAll() {
        isFinish = false
        pfmMonthsHistory = nil
        helper?.delegate = nil
        helper?.cancelAll()
        helper = nil
        handler.reset()
    }
    
    func finishSession () {
        subscribers = []
        cancelAll()
    }
    
    func calculatePfm() {
        if isFinish {
            helper?.getPfm()
        }
    }
}

// MARK: - LoadPfmSuperUseCaseDelegate

extension LoadPfmSuperUseCase: LoadPfmSuperUseCaseDelegate {
    func informCardFinished(card: CardEntity) {
        DispatchQueue.main.async {
            for unretainedSubscriber in self.subscribers {
                unretainedSubscriber.reference?.pfmEndCard(card: card)
            }
            if self.moduleSubscribers.count > 0 {
                for unretainedSubscriber in self.moduleSubscribers {
                    unretainedSubscriber.reference?.finishedPFMCard(card: card)
                }
            }
        }
    }
    
    func informAccountFinished(account: AccountEntity) {
        DispatchQueue.main.async {
            for unretainedSubscriber in self.subscribers {
                unretainedSubscriber.reference?.pfmEndAccount(account: account)
            }
            if self.moduleSubscribers.count > 0 {
                for unretainedSubscriber in self.moduleSubscribers {
                    unretainedSubscriber.reference?.finishedPFMAccount(account: account)
                }
            }
        }
    }
    
    func finish(months: [MonthlyBalanceRepresentable]) {
        isFinish = true
        pfmMonthsHistory = months
        DispatchQueue.main.async {
            for unretainedSubscriber in self.subscribers {
                unretainedSubscriber.reference?.pfmDidFinish(months: months)
            }
            if self.moduleSubscribers.count > 0 {
                for unretainedSubscriber in self.moduleSubscribers {
                    unretainedSubscriber.reference?.finishedPFM(months: months)
                }
            }
        }
    }
    
}

// MARK: - PfmControllerProtocol

extension LoadPfmSuperUseCase: PfmControllerProtocol {
    var monthsHistory: [MonthlyBalanceRepresentable]? {
        get {
            return pfmMonthsHistory
        }
        set(newValue) {
            self.pfmMonthsHistory = newValue
        }
    }
    
    func isPFMCardReady(card: CardEntity) -> Bool {
        return isEndCard(card: card)
    }
    
    func isPFMAccountReady(account: AccountEntity) -> Bool {
        return isEndAccount(account: account)
    }
    
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        if let index = self.moduleSubscribers.firstIndex(where: { $0.reference.map({ String(describing: $0) }) == String(describing: subscriber) }) {
            self.moduleSubscribers.remove(at: index)
        }
        let unretainedSubscriber = WeakReference<PfmControllerSubscriber>(reference: subscriber)
        self.moduleSubscribers.append(unretainedSubscriber)
    }
    
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        let index = self.moduleSubscribers.firstIndex {
            return $0.reference === subscriber
        }
        guard let indexSubscriber: Int = index else { return }
        self.moduleSubscribers.remove(at: indexSubscriber)
    }
}

// MARK: - PfmHelperProtocol

extension LoadPfmSuperUseCase: PfmHelperProtocol {
    func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let transactions = pfmHelper.unreadAccountMovements(account: account, startDate: startDate, limit: limit).map {
        AccountTransactionEntity($0.dto) }
        return transactions
    }
    
    func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.unreadCardMovements(card: card, startDate: startDate, limit: limit).compactMap {
            guard case .list(cardTransaction: let transaction) = $0.transaction else { return nil }
            return CardTransactionEntity(transaction.dto)
        }
    }
    
    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date? = nil) -> [AccountTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let transactions = pfmHelper.searchAccountTransactions(account: account, searchText: searchText, fromDate: date, toDate: toDate).map {
            AccountTransactionEntity($0.dto) }
        return transactions
    }
    
    func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let amount = pfmHelper.cardExpensesCalculationTransaction(card: card)
        return amount
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.searchLastsCardTransactions(card: card).compactMap {
            guard case .list(cardTransaction: let transaction) = $0.transaction else { return nil }
            return CardTransactionEntity(transaction.dto)
        }
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let pfmResult = pfmHelper.searchCardTransactions(card: card, startDate: startDate, endDate: endDate)
        return pfmResult.compactMap({
            guard case .list(cardTransaction: let transaction) = $0.transaction else { return nil }
            return CardTransactionEntity(transaction.dto)
        })
    }
    
    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date? = nil) -> [CardTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let pfmResult = pfmHelper.searchCardTransactions(card: card, searchText: searchText, fromDate: fromDate, endDate: toDate)
        return pfmResult.compactMap({
            guard case .list(cardTransaction: let transaction) = $0.transaction else { return nil }
            return CardTransactionEntity(transaction.dto)
        })
    }
    
    func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.searchAccountTransactions(account: account, searchText: "", fromDate: date).map {
            AccountTransactionEntity($0.dto)
        }
    }
    
    func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.searchAccountTransactions(account: account, searchText: matches, limit: limit, startDate: date).map {
            AccountTransactionEntity($0.dto)
        }
    }
    
    func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.searchCardTransactions(card: card, searchText: matches, limit: limit, startDate: date).compactMap {
            guard case .list(cardTransaction: let transaction) = $0.transaction else { return nil }
            return CardTransactionEntity(transaction.dto)
        }
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int? {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.getCountUnreadAccountMovements(account: account)
    }
    
    func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int? {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        return pfmHelper.getCountUnreadCardMovements(card: card)
    }
    
    func setReadMovements(for userId: String, account: AccountEntity) {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        pfmHelper.setReadAllAccountMovements(account: account)
    }
    
    func setReadMovements(for userId: String, card: CardEntity) {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        pfmHelper.setReadAllCardMovements(card: card)
    }
    
    func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity] {
        let pfmHelper: PfmHelper = PfmHelper(userId: userId)
        let transactions = pfmHelper.accountTransactionsExcludingInternal(userId: userId, account: account, startDate: startDate, endDate: endDate, includeInternalTransfers: includeInternalTransfers).map {
            AccountTransactionEntity($0.dto)
        }
        return transactions
    }
    
    func execute() {
        Scenario(useCase: globalPositionUseCase)
            .execute(on: useCaseHandler)
            .onSuccess { [weak self] result in
                let accounts = result.globalPosition.accounts.all()
                let cards = result.globalPosition.cards.all()
                let userId = result.globalPosition.userCodeType ?? ""
                self?.execute(accounts: accounts, cards: cards, userId: userId)
            }
    }
    
    func finishSession(_ reason: SessionFinishedReason?) {
        finishSession()
    }
}
