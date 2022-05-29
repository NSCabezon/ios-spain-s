import Foundation
import CoreDomain
import OpenCombine

public protocol GetLoanTransactionDetailConfigurationUseCase {
    func fetchLoanTransactionDetailConfiguration() -> AnyPublisher<LoanTransactionDetailConfigurationRepresentable, Never>
}
