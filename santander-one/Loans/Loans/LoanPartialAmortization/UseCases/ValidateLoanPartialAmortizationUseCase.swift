import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol ValidateLoanPartialAmortizationUseCaseProtocol: UseCase<ValidateLoanPartialAmortizationUseCaseInput, ValidateLoanPartialAmortizationUseCaseOKOutput, StringErrorOutput> {}

public class ValidateLoanPartialAmortizationUseCase: UseCase<ValidateLoanPartialAmortizationUseCaseInput, ValidateLoanPartialAmortizationUseCaseOKOutput, StringErrorOutput> {
    
    let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
  public override func executeUseCase(requestValues: ValidateLoanPartialAmortizationUseCaseInput) throws -> UseCaseResponse<ValidateLoanPartialAmortizationUseCaseOKOutput, StringErrorOutput> {
        let repository = self.dependenciesResolver.resolve(for: LoansRepository.self)
        let secondResponse = try repository.validateLoanPartialAmortization(
            requestValues.loanPartialAmortization,
            amount: requestValues.amount,
            amortizationType: requestValues.amortizationType)
        switch secondResponse {
        case .success(let loanValidationRepresentable):
            return .ok(ValidateLoanPartialAmortizationUseCaseOKOutput(loanValidation: loanValidationRepresentable))
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}
    
extension ValidateLoanPartialAmortizationUseCase: ValidateLoanPartialAmortizationUseCaseProtocol {}

public struct ValidateLoanPartialAmortizationUseCaseInput {
    let loanPartialAmortization: LoanPartialAmortizationRepresentable
    let amount: AmountRepresentable
    let amortizationType: PartialAmortizationTypeRepresentable
}

public struct ValidateLoanPartialAmortizationUseCaseOKOutput {
    let loanValidation: LoanValidationRepresentable
}
