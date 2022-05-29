import CoreFoundationLib
import CoreDomain
import SANLegacyLibrary

public protocol GetNewMortgageLawPDFUseCaseProtocol: UseCase<GetNewMortgageLawPDFUseCaseInput, GetNewMortgageLawPDFUseCaseOKOutput, StringErrorOutput> {}

public class SpainGetNewMortgageLawPDFUseCase: UseCase<GetNewMortgageLawPDFUseCaseInput, GetNewMortgageLawPDFUseCaseOKOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    override public func executeUseCase(requestValues: GetNewMortgageLawPDFUseCaseInput) throws -> UseCaseResponse<GetNewMortgageLawPDFUseCaseOKOutput, StringErrorOutput> {
        let repository = self.dependenciesResolver.resolve(for: LoansRepository.self)
        let response = try repository.downloadPDF(requestValues.loanPartialAmortization,
                                                  amount: requestValues.amount,
                                                  amortizationType: requestValues.amortizationType)
        switch response {
        case .success(let loanPdfRepresentable):
            return .ok(GetNewMortgageLawPDFUseCaseOKOutput(document: loanPdfRepresentable))
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension SpainGetNewMortgageLawPDFUseCase: GetNewMortgageLawPDFUseCaseProtocol {}

public struct GetNewMortgageLawPDFUseCaseInput {
    let loanPartialAmortization: LoanPartialAmortizationRepresentable
    let amount: AmountRepresentable
    let amortizationType: PartialAmortizationTypeRepresentable

    public init(loanPartialAmortization: LoanPartialAmortizationRepresentable, amount: AmountRepresentable, amortizationType: PartialAmortizationTypeRepresentable) {
        self.loanPartialAmortization = loanPartialAmortization
        self.amount = amount
        self.amortizationType = amortizationType
    }
}

public struct GetNewMortgageLawPDFUseCaseOKOutput {
    public let document: LoanPdfRepresentable

    public init(document: LoanPdfRepresentable) {
        self.document = document
    }
}
