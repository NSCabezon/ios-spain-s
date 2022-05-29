import CoreDomain
import OpenCombine


public class MockSavingTransactionsRepository: SavingTransactionsRepository {
    public var getSavingProductTransactions: MockSavingProductTransactionsListDTO!
    
    public init(getSavingProductTransactions: MockSavingProductTransactionsListDTO) {
        self.getSavingProductTransactions = getSavingProductTransactions
    }
    
    public func getTransactions(_ parameters: SavingTransactionParamsRepresentable) -> AnyPublisher<SavingTransactionsResponseRepresentable, Error> {
        Just(getSavingProductTransactions).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
