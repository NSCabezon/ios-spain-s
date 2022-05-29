import OpenCombine

public protocol SavingTransactionsRepository {
    func getTransactions(_ parameters: SavingTransactionParamsRepresentable) -> AnyPublisher<SavingTransactionsResponseRepresentable, Error>
}
