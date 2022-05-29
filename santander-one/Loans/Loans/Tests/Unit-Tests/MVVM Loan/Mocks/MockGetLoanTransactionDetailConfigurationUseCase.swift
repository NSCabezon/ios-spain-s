import Foundation
import Loans
import OpenCombine

struct MockGetLoanTransactionDetailConfigurationUseCase: GetLoanTransactionDetailConfigurationUseCase {
    private var fields: LoanTransactionDetailConfigurationRepresentable
    
    init(_ fields: LoanTransactionDetailConfigurationRepresentable) {
        self.fields = fields
    }
    
    func fetchLoanTransactionDetailConfiguration() -> AnyPublisher<LoanTransactionDetailConfigurationRepresentable, Never> {
        return Just(self.fields).eraseToAnyPublisher()
    }
}

struct LoanTransactionDetailConfigurationMock: LoanTransactionDetailConfigurationRepresentable {
    let fields: [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)]
    
    init(_ config: LoanTransactionDetailConfiguration) {
        self.fields = config.fields()
    }
}

enum LoanTransactionDetailConfiguration {
    case full
    case empty
    func fields() -> [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)] {
        return [(LoanTransactionDetailFieldMock(value: .operationDate),
                 LoanTransactionDetailFieldMock(value: .valueDate))]
    }
}

private struct LoanTransactionDetailFieldMock: LoanTransactionDetailFieldRepresentable {
    var title: String = ""
    var titleAccessibility: String = ""
    var value: LoanTransactionDetailValueField
    var valueAccessibility: String = ""
}
