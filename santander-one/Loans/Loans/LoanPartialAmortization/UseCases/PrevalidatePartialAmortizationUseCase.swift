import CoreFoundationLib
import Operative
import SANLegacyLibrary
import CoreDomain

protocol PrevalidatePartialAmortizationUseCaseProtocol: UseCase<PrevalidatePartialAmortizationUseCaseInput, PrevalidatePartialAmortizationUseCaseOKOutput, StringErrorOutput> {}

class PrevalidatePartialAmortizationUseCase: UseCase<PrevalidatePartialAmortizationUseCaseInput, PrevalidatePartialAmortizationUseCaseOKOutput, StringErrorOutput> {

    let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }

    override func executeUseCase(requestValues: PrevalidatePartialAmortizationUseCaseInput) throws -> UseCaseResponse<PrevalidatePartialAmortizationUseCaseOKOutput, StringErrorOutput> {
        let repository = self.dependenciesResolver.resolve(for: LoansRepository.self)
        let response = try repository.getLoanPartialAmortization(requestValues.loan)
        switch response {
        case .success(let loanPartialAmortizationRepresentable):
            let secondResponse = try repository.validateLoanPartialAmortization(
                loanPartialAmortizationRepresentable,
                amount: requestValues.amount,
                amortizationType: requestValues.amortizationType)
            switch secondResponse {
            case .success(let loanValidationRepresentable):
                return .ok(PrevalidatePartialAmortizationUseCaseOKOutput(partialLoan: loanPartialAmortizationRepresentable, loanValidation: loanValidationRepresentable))
            case .failure(let error):
                return .error(StringErrorOutput(error.localizedDescription))
            }
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension PrevalidatePartialAmortizationUseCase: PrevalidatePartialAmortizationUseCaseProtocol {}

struct PrevalidatePartialAmortizationUseCaseInput {
    let loan: LoanRepresentable
    let amount: AmountRepresentable
    let amortizationType: PartialAmortizationTypeRepresentable
}

struct PrevalidatePartialAmortizationUseCaseOKOutput {
    let partialLoan: LoanPartialAmortizationRepresentable
    let loanValidation: LoanValidationRepresentable
}
