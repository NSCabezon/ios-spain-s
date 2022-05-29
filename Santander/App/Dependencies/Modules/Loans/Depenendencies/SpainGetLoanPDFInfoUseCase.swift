import Foundation
import Loans
import OpenCombine

struct SpainGetLoanPDFInfoUseCase: GetLoanPDFInfoUseCase {
    func fetchLoanPDFInfo(receiptId: String) -> AnyPublisher<Data?, Never> {
        return Just(nil).eraseToAnyPublisher()
    }
}
