import Foundation
import Loans
import OpenCombine

struct MockGetLoanPDFInfoUseCase: GetLoanPDFInfoUseCase {
    let dataToMock: Data?
    
    init(_ data: Data?) {
        self.dataToMock = data
    }
    func fetchLoanPDFInfo(receiptId: String) -> AnyPublisher<Data?, Never> {
        return Just(self.dataToMock).eraseToAnyPublisher()
    }
}
