import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetAccountDetailUseCase: UseCase<GetAccountDetailUseCaseInput, GetAccountDetailUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountDetailUseCaseInput) throws -> UseCaseResponse<GetAccountDetailUseCaseOkOutput, StringErrorOutput> {
        let provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let accountsManager = provider.getBsanAccountsManager()
        let response = try accountsManager.getAccountDetail(forAccount: requestValues.account.dto)
        var availableName: String
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        if let holder = data.holder, !holder.isBlank {
            availableName = holder.capitalizingFirstLetter().camelCasedString
        } else {
            let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
            availableName = globalPosition.completeName ?? globalPosition.availableName ?? ""
        }
        
        return .ok(GetAccountDetailUseCaseOkOutput(detail: AccountDetailEntity(data), holder: availableName))
    }
}

struct GetAccountDetailUseCaseInput {
    let account: AccountEntity
}

struct GetAccountDetailUseCaseOkOutput {
    let detail: AccountDetailEntity
    let holder: String
}
