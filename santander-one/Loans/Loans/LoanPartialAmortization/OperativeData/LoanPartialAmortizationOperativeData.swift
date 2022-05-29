import Foundation
import CoreFoundationLib
import CoreDomain

public final class LoanPartialAmortizationOperativeData {
    var selectedLoan: LoanRepresentable
    var selectedLoanDetail: LoanDetailRepresentable?
    var amortizationAmount: AmountRepresentable?
    var amortizationType: PartialAmortizationTypeRepresentable?
    var partialAmortization: LoanPartialAmortizationRepresentable?
    var partialLoanAmortizationValidation: LoanValidationRepresentable?
    var account: AccountRepresentable?
    var signatureSupportPhone: String?
    var pendingCapital: AmountRepresentable?
    public var newMortgageLawConditionsReviewed: Bool?

    public init(_ selectedLoan: LoanRepresentable) {
        self.selectedLoan = selectedLoan
    }

    public func getSelectedLoan() -> LoanRepresentable {
        selectedLoan
    }

    public func getAmortizationAmount() -> AmountRepresentable? {
        amortizationAmount
    }

    public func getAmortizationType() -> PartialAmortizationTypeRepresentable? {
        amortizationType
    }

    public func getPartialAmortization() -> LoanPartialAmortizationRepresentable? {
        partialAmortization
    }

    public func getPartialLoanAmortizationValidation() -> LoanValidationRepresentable? {
        partialLoanAmortizationValidation
    }
}
