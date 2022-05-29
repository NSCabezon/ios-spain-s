import Foundation
import CoreDomain
import CoreFoundationLib
import Loans
import OpenCombine

struct SpainGetLoanTransactionDetailConfigurationUseCase { }

extension SpainGetLoanTransactionDetailConfigurationUseCase: GetLoanTransactionDetailConfigurationUseCase {
    func fetchLoanTransactionDetailConfiguration() -> AnyPublisher<LoanTransactionDetailConfigurationRepresentable, Never> {
        return Just(SpainLoanTransactionDetailConfiguration())
            .eraseToAnyPublisher()
    }
}

extension SpainGetLoanTransactionDetailConfigurationUseCase: GetLoanTransactionDetailActionUseCase {
    func fetchLoanTransactionDetailActions(transaction: LoanTransactionRepresentable) -> AnyPublisher<[LoanTransactionDetailActionRepresentable], Never> {
        return Just(detailActions())
            .eraseToAnyPublisher()
    }
}

private extension SpainGetLoanTransactionDetailConfigurationUseCase {
    func detailActions() -> [LoanTransactionDetailActionRepresentable] {
        return [SpainLoanTransactionDetailAction(type: LoanTransactionDetailActionType.partialAmortization,
                                                 isDisabled: false,
                                                 isUserInteractionEnable: true),
                SpainLoanTransactionDetailAction(type: LoanTransactionDetailActionType.changeAccount,
                                                 isDisabled: false,
                                                 isUserInteractionEnable: true),
                SpainLoanTransactionDetailAction(type: LoanTransactionDetailActionType.showDetail,
                                                 isDisabled: false,
                                                 isUserInteractionEnable: true),
                SpainLoanTransactionDetailAction(type: LoanTransactionDetailActionType.share,
                                                 isDisabled: false,
                                                 isUserInteractionEnable: true)]
    }
}

struct SpainLoanTransactionDetailConfiguration: LoanTransactionDetailConfigurationRepresentable {
    var fields: [(LoanTransactionDetailFieldRepresentable, LoanTransactionDetailFieldRepresentable?)] =
    [(SpainLoanTransactionDetailField(title: "transaction_label_operationDate",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.transactionDateDescription.rawValue,
                                      value: .operationDate,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.transactionDateValue.rawValue),
      SpainLoanTransactionDetailField(title: "transaction_label_valueDate",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.effectiveDateDescription.rawValue,
                                      value: .valueDate,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.effectiveDateValue.rawValue)),
     (SpainLoanTransactionDetailField(title: "transaction_label_feeAmount",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.feeAmountDescription.rawValue,
                                      value: .feeAmount,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.feeAmountValue.rawValue),
      SpainLoanTransactionDetailField(title: "transaction_label_amount",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.capitalAmountDescription.rawValue,
                                      value: .capitalAmount,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.capitalAmountValue.rawValue)),
     (SpainLoanTransactionDetailField(title: "transaction_label_interests",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.interestAmountDescription.rawValue,
                                      value: .interestsAmount,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.interestAmountValue.rawValue),
      SpainLoanTransactionDetailField(title: "transaction_label_pendingAmount",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.pendingAmountDescription.rawValue,
                                      value: .pendingCapitalAmount,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.pendingAmountValue.rawValue)),
     (SpainLoanTransactionDetailField(title: "transaction_label_recipientAccount",
                                      titleAccessibility: AccessibilityIDLoansTransactionsDetail.recipientAccountDescription.rawValue,
                                      value: .recipientAccount,
                                      valueAccessibility: AccessibilityIDLoansTransactionsDetail.recipientAccountValue.rawValue),
      nil)]
}

private extension SpainLoanTransactionDetailConfiguration {
    struct SpainLoanTransactionDetailField: LoanTransactionDetailFieldRepresentable {
        var title: String
        var titleAccessibility: String
        var value: LoanTransactionDetailValueField
        var valueAccessibility: String
    }
}

struct SpainLoanTransactionDetailAction: LoanTransactionDetailActionRepresentable {
    var type: LoanTransactionDetailActionType
    var isDisabled: Bool
    var isUserInteractionEnable: Bool
}
