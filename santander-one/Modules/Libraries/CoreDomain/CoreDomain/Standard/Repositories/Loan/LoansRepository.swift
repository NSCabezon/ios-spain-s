//
//  LoansRepository.swift
//  SANSpainLibrary
//
//  Created by Andres Aguirre Juarez on 13/10/21.
//

import Foundation

public protocol LoansRepository: ParseSignature {
    func getLoanDetail(_ loan: LoanRepresentable) throws -> Result<LoanDetailRepresentable, Error>
    func getLoanPartialAmortization(_ loan: LoanRepresentable) throws -> Result<LoanPartialAmortizationRepresentable, Error>
    func confirmLoanPartialAmortization(_ loanPartialAmortization: LoanPartialAmortizationRepresentable,
                                        amortizationType: PartialAmortizationTypeRepresentable,
                                        loanValidation: LoanValidationRepresentable,
                                        signature: SignatureRepresentable,
                                        amount: AmountRepresentable) throws -> Result<Void, Error>
    
    func validateLoanPartialAmortization(_ loanPartialAmortization: LoanPartialAmortizationRepresentable,
                                         amount: AmountRepresentable,
                                         amortizationType: PartialAmortizationTypeRepresentable) throws -> Result<LoanValidationRepresentable, Error>
    func downloadPDF(_ loanPartialAmortization: LoanPartialAmortizationRepresentable,
                     amount: AmountRepresentable,
                     amortizationType: PartialAmortizationTypeRepresentable) throws -> Result<LoanPdfRepresentable, Error>
}
