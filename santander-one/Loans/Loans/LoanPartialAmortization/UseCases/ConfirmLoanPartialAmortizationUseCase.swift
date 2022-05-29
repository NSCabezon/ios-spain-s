//
//  ConfirmLoanPartialAmortizationUseCase.swift
//  Loans
//
//  Created by Andres Aguirre Juarez on 6/10/21.
//

import CoreDomain
import CoreFoundationLib
import SANLegacyLibrary

protocol ConfirmLoanPartialAmortizationUseCaseProtocol: UseCase<ConfirmLoanPartialAmortizationUseCaseInput, ConfirmLoanPartialAmortizationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {}

class ConfirmLoanPartialAmortizationUseCase: UseCase<ConfirmLoanPartialAmortizationUseCaseInput, ConfirmLoanPartialAmortizationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: ConfirmLoanPartialAmortizationUseCaseInput) throws -> UseCaseResponse<ConfirmLoanPartialAmortizationUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let repository = self.dependenciesResolver.resolve(for: LoansRepository.self)
        let response = try repository.confirmLoanPartialAmortization(
            requestValues.loanPartialAmortization,
            amortizationType: requestValues.amortizationType,
            loanValidation: requestValues.loanValidation,
            signature: requestValues.signature,
            amount: requestValues.amount)
        switch response {
        case .success: return .ok(ConfirmLoanPartialAmortizationUseCaseOkOutput())
        case .failure(let error):
            let nsError = error as NSError
            let signatureResult = try repository.processSignatureResult(nsError)
            return .error(GenericErrorSignatureErrorOutput(nsError.localizedDescription, signatureResult, nsError.errorCode))
        }
    }
}

extension ConfirmLoanPartialAmortizationUseCase: ConfirmLoanPartialAmortizationUseCaseProtocol {}

struct ConfirmLoanPartialAmortizationUseCaseInput {
    let loanPartialAmortization: LoanPartialAmortizationRepresentable
    let amortizationType: PartialAmortizationTypeRepresentable
    let loanValidation: LoanValidationRepresentable
    let signature: SignatureRepresentable
    let amount: AmountRepresentable
}

struct ConfirmLoanPartialAmortizationUseCaseOkOutput { }
