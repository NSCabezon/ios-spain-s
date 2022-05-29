import Foundation
import CoreDomain
import OpenCombine

public struct GetLoanTransactionDetailConfigurationUseCaseMock: GetLoanTransactionDetailConfigurationUseCase {
    public init() {}
    
    public func fetchLoanTransactionDetailConfiguration() -> AnyPublisher<LoanTransactionDetailConfigurationRepresentable, Never> {
        return Just(LoanTransactionDetailConfigurationMock())
            .eraseToAnyPublisher()
    }
}

private extension GetLoanTransactionDetailConfigurationUseCaseMock {
    struct LoanTransactionDetailConfigurationMock: LoanTransactionDetailConfigurationRepresentable {
        var fields: [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)] =
        [(LoanTransactionDetailFieldMock(title: "transaction_label_operationDate",
                                       titleAccessibility: "transactionDateDescription",
                                       value: .operationDate,
                                       valueAccessibility: "transactionDateValue"),
          LoanTransactionDetailFieldMock(title: "transaction_label_valueDate",
                                       titleAccessibility: "effectiveDateDescription",
                                       value: .valueDate,
                                       valueAccessibility: "effectiveDateValue")),
         (LoanTransactionDetailFieldMock(title: "transaction_label_amount",
                                       titleAccessibility: "capitalAmountDescription",
                                       value: .capitalAmount,
                                       valueAccessibility: "capitalAmountValue"),
          LoanTransactionDetailFieldMock(title: "transaction_label_interests",
                                       titleAccessibility: "interestAmountDescription",
                                       value: .interestsAmount,
                                       valueAccessibility: "interestAmountValue")
         ),
         (LoanTransactionDetailFieldMock(title: "transaction_label_recipientAccount",
                                       titleAccessibility: "recipientAccountDescriptio",
                                       value: .recipientAccount,
                                       valueAccessibility: "recipientAccountValue"),
          nil),
         (LoanTransactionDetailFieldMock(title: "transaction_label_recipientData",
                                       titleAccessibility: "recipientDataDescription",
                                       value: .recipientData,
                                       valueAccessibility: "recipientDataValue"),
          nil)]
    }
    
    struct LoanTransactionDetailFieldMock: LoanTransactionDetailFieldRepresentable {
        var title: String
        var titleAccessibility: String
        var value: LoanTransactionDetailValueField
        var valueAccessibility: String
    }
}
