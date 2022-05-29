import Foundation
import OpenCombine

public struct GetLoanPDFInfoUseCaseMock: GetLoanPDFInfoUseCase {
    public init() {}
    
    public func fetchLoanPDFInfo(receiptId: String) -> AnyPublisher<Data?, Never> {
        return Just(nil).eraseToAnyPublisher()
    }
}
