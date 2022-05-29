import CoreDomain

public protocol PfmControllerProtocol: AnyObject {
    var monthsHistory: [MonthlyBalanceRepresentable]? { get set }
    var isFinish: Bool { get }
    func isPFMAccountReady(account: AccountEntity) -> Bool
    func isPFMCardReady(card: CardEntity) -> Bool
    func registerPFMSubscriber(with subscriber: PfmControllerSubscriber)
    func removePFMSubscriber(_ subscriber: PfmControllerSubscriber)
    func cancelAll()
}

public protocol PfmControllerSubscriber: AnyObject {
    func finishedPFMAccount(account: AccountEntity)
    func finishedPFMCard(card: CardEntity)
    func finishedPFM(months: [MonthlyBalanceRepresentable])
}

public protocol PfmHelperProtocol: AnyObject {
    func getMovementsFor(userId: String, date: Date, account: AccountEntity) -> [AccountTransactionEntity]
    func getMovementsFor(userId: String, matches: String, account: AccountEntity, limit: Int, date: Date) -> [AccountTransactionEntity]
    func getMovementsFor(userId: String, matches: String, card: CardEntity, limit: Int, date: Date) -> [CardTransactionEntity]
    func getLastMovementsFor(userId: String, card: CardEntity) -> [CardTransactionEntity]
    func getLastMovementsFor(userId: String, card: CardEntity, startDate: Date, endDate: Date) -> [CardTransactionEntity]
    func getLastMovementsFor(userId: String, card: CardEntity, searchText: String, fromDate: Date, toDate: Date?) -> [CardTransactionEntity]
    func getUnreadMovementsFor(userId: String, date: Date, account: AccountEntity) -> Int?
    func getUnreadMovementsFor(userId: String, date: Date, card: CardEntity) -> Int?
    func cardExpensesCalculationTransaction(userId: String, card: CardEntity) -> AmountEntity
    func setReadMovements(for userId: String, account: AccountEntity)
    func setReadMovements(for userId: String, card: CardEntity)
    func getMovementsFor(userId: String, date: Date, account: AccountEntity, searchText: String, toDate: Date?) -> [AccountTransactionEntity]
    func getMovementsFor(userId: String, account: AccountEntity, startDate: Date, endDate: Date, includeInternalTransfers: Bool) -> [AccountTransactionEntity]
    func getUnreadCardMovementsFor(userId: String, startDate: Date, card: CardEntity, limit: Int?) -> [CardTransactionEntity]
    func getUnreadAccountMovementsFor(userId: String, startDate: Date, account: AccountEntity, limit: Int?) -> [AccountTransactionEntity]
    func execute()
    func finishSession(_ reason: SessionFinishedReason?)
}
