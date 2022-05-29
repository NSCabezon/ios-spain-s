import Foundation
import CoreDomain
import OpenCombine

public protocol GetLoanTransactionDetailUseCase {
    func fetchLoanTransactionDetail(loan: LoanRepresentable, transaction: LoanTransactionRepresentable) -> AnyPublisher<LoanTransactionDetailRepresentable, Error>
}

final class DefaultGetLoanTransactionDetailUseCase {
    private let repository: LoanReactiveRepository
    
    init(dependencies: LoanTransactionDetailDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGetLoanTransactionDetailUseCase: GetLoanTransactionDetailUseCase {
    func fetchLoanTransactionDetail(loan: LoanRepresentable, transaction: LoanTransactionRepresentable) -> AnyPublisher<LoanTransactionDetailRepresentable, Error> {
        self.repository.loadTransactionDetail(transaction: transaction, loan: loan)
    }
}
