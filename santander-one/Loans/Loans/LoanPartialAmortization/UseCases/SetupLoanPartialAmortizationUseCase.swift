import CoreFoundationLib
import Operative
import SANLegacyLibrary
import CoreDomain

protocol SetupLoanPartialAmortizationUseCaseProtocol: UseCase<SetupLoanPartialAmortizationUseCaseInput, SetupLoanPartialAmortizationUseOkOutput, StringErrorOutput> { }

class SetupLoanPartialAmortizationUseCase: UseCase<SetupLoanPartialAmortizationUseCaseInput, SetupLoanPartialAmortizationUseOkOutput, StringErrorOutput> {
    
    let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: SetupLoanPartialAmortizationUseCaseInput) throws -> UseCaseResponse<SetupLoanPartialAmortizationUseOkOutput, StringErrorOutput> {
        let repository = self.dependenciesResolver.resolve(for: LoansRepository.self)
        let response = try repository.getLoanDetail(requestValues.loan)
        switch response {
        case .success(let loanDetailRepresentable):
            var account: AccountEntity?
            let accountsManager = provider.getBsanAccountsManager()
            guard let contractDTO = loanDetailRepresentable.linkedAccountContractRepresentable as? ContractDTO else { return .error(StringErrorOutput("Se ha producido un error"))}
            let accountResponse = try accountsManager.getAccount(fromOldContract: contractDTO)
            if accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() {
                account = AccountEntity(accountDTO)
            }
            return .ok(SetupLoanPartialAmortizationUseOkOutput(loanDetail: loanDetailRepresentable, account: account?.dto))
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}

extension SetupLoanPartialAmortizationUseCase: SetupLoanPartialAmortizationUseCaseProtocol {}

struct SetupLoanPartialAmortizationUseCaseInput {
    let loan: LoanRepresentable
}

struct SetupLoanPartialAmortizationUseOkOutput {
    let loanDetail: LoanDetailRepresentable
    let account: AccountRepresentable?
}
