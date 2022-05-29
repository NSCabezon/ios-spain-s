import SANLegacyLibrary
import CoreFoundationLib

class PrevalidateChangeLinkedAccountUseCase: UseCase<PrevalidateChangeLinkedAccountUseCaseInput, PrevalidateChangeLinkedAccountUseCaseOkOutput, PrevalidateChangeLinkedAccountUseCaseErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: PrevalidateChangeLinkedAccountUseCaseInput) throws -> UseCaseResponse<PrevalidateChangeLinkedAccountUseCaseOkOutput, PrevalidateChangeLinkedAccountUseCaseErrorOutput> {
        
        let accountsManager = provider.getBsanAccountsManager()
        
        let accountDto = requestValues.account.accountDTO
        
        let response = try accountsManager.getAccountDetail(forAccount: accountDto)
        
        guard response.isSuccess(), let detail = try response.getResponseData() else {
            return UseCaseResponse.error(PrevalidateChangeLinkedAccountUseCaseErrorOutput(try response.getErrorMessage() ?? ""))
        }
        return UseCaseResponse.ok(PrevalidateChangeLinkedAccountUseCaseOkOutput(accountDetail: AccountDetail.create(accountDto, detailDTO: detail)))
        
    }
    
}

struct PrevalidateChangeLinkedAccountUseCaseInput {
    let account: Account
}

struct PrevalidateChangeLinkedAccountUseCaseOkOutput {
    let accountDetail: AccountDetail
}

class PrevalidateChangeLinkedAccountUseCaseErrorOutput: StringErrorOutput {
    
}
