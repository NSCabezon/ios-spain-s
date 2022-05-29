//

import SANLegacyLibrary
import CoreFoundationLib

class GetAccountDetailUseCase: UseCase<GetAccountDetailUseCaseInput, GetAccountDetailUseCaseOKOutput, GetAccountDetailUseCaseErrorOutput> {
    
    let provider: BSANManagersProvider
    let dependenciesResolver: DependenciesResolver

    init(managerProvider: BSANManagersProvider, dependenciesResolver: DependenciesResolver) {
        self.provider = managerProvider
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountDetailUseCaseInput) throws -> UseCaseResponse<GetAccountDetailUseCaseOKOutput, GetAccountDetailUseCaseErrorOutput> {
        
        let bsanAccountManager = provider.getBsanAccountsManager()
        let accountDTO = requestValues.account.accountDTO
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let response = try bsanAccountManager.getAccountDetail(forAccount: accountDTO)
        if response.isSuccess(), let detailDTO = try response.getResponseData() {
            let accountDetail = AccountDetail.create(accountDTO, detailDTO: detailDTO)
            let availableName = globalPosition.completeName ?? globalPosition.availableName ?? ""
            return UseCaseResponse.ok(GetAccountDetailUseCaseOKOutput(accountDetail: accountDetail, holder: availableName))
        }
        let errorMessage = try response.getErrorMessage()
        return UseCaseResponse.error(GetAccountDetailUseCaseErrorOutput(errorMessage))
    }
}

// MARK: - Input
struct GetAccountDetailUseCaseInput {
    let account: Account
    
    init(account: Account) { self.account = account}
}

// MARK: - OK output
struct GetAccountDetailUseCaseOKOutput {
    private let accountDetail: AccountDetail
    private let holder: String
    init(accountDetail: AccountDetail, holder: String) {
        self.accountDetail = accountDetail
        self.holder = holder
    }
    func getAccountDetail() -> AccountDetail {
        return accountDetail
    }
    func getHolder() -> String {
        return holder
    }
}

// MARK: - Error output
class GetAccountDetailUseCaseErrorOutput: StringErrorOutput {
    override init(_ errorDesc: String?) {
        super.init(errorDesc)
    }
}
