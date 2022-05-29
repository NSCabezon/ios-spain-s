import Foundation
import CoreDomain
import OpenCombine

public struct GetLoanTransactionDetailActionUseCaseMock: GetLoanTransactionDetailActionUseCase {
    public init() {}
    
    public func fetchLoanTransactionDetailActions() -> AnyPublisher<[LoanTransactionDetailActionRepresentable], Never> {
        return Just([LoanTransactionDetailActionRepresentableMock(type: .pdfExtract(nil)),
                     LoanTransactionDetailActionRepresentableMock(type: .share)])
            .eraseToAnyPublisher()
    }
}

private extension GetLoanTransactionDetailActionUseCaseMock {
    struct LoanTransactionDetailActionRepresentableMock: LoanTransactionDetailActionRepresentable {
        var type: LoanTransactionDetailActionType
        var isDisabled: Bool = false
        var isUserInteractionEnable: Bool = true
    }
}
