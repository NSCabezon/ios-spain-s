import SANLegacyLibrary
import CoreFoundationLib

protocol GetLoanDetailUseCaseProtocol: UseCase<GetLoanDetailUseCaseInput, GetLoanDetailUseCaseOkOutput, StringErrorOutput> {}

class GetLoanDetailUseCase: UseCase<GetLoanDetailUseCaseInput, GetLoanDetailUseCaseOkOutput, StringErrorOutput> {
    
    let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetLoanDetailUseCaseInput) throws -> UseCaseResponse<GetLoanDetailUseCaseOkOutput, StringErrorOutput> {
        let loansManager = provider.getBsanLoansManager()
        guard let loanDTO = requestValues.loan.representable as? LoanDTO else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let response = try loansManager.getLoanDetail(forLoan: loanDTO)
        
        if response.isSuccess(), let detailDTO = try response.getResponseData() {
            return UseCaseResponse.ok(GetLoanDetailUseCaseOkOutput(loanDetail: LoanDetailEntity(detailDTO)))
        }
        
        let errorMessage = try response.getErrorMessage()
        return UseCaseResponse.error(StringErrorOutput(errorMessage))
    }
}

extension GetLoanDetailUseCase: GetLoanDetailUseCaseProtocol {}

struct GetLoanDetailUseCaseInput {
    let loan: LoanEntity
}

struct GetLoanDetailUseCaseOkOutput {
    let loanDetail: LoanDetailEntity
}
