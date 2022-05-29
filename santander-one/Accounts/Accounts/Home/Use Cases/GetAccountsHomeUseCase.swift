import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetAccountsHomeUseCase: UseCase<Void, GetAccountsHomeUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAccountsHomeUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let configuration: AccountsHomeConfiguration = dependenciesResolver.resolve(for: AccountsHomeConfiguration.self)
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isCrossSellingEnabled = appConfigRepository.getBool("enableAccountMovementsCrossSelling") == true
        let accountsCrossSellingEntity = appConfigRepository
            .getAppConfigListNode(
                "listAccountMovementsCrossSelling",
                object: AccountMovementsCrossSellingEntity.self,
                options: .json5Allowed) ?? []
        let accountsCrossSellingViewModel = accountsCrossSellingEntity
            .map(AccountMovementsCrossSellingProperties.init)
        return .ok(
            GetAccountsHomeUseCaseOkOutput(
                accounts: globalPosition.accounts.visibles(),
                configuration: configuration,
                isCrossSellingEnabled: isCrossSellingEnabled,
                accountsCrossSelling: accountsCrossSellingViewModel
            ))
    }
}

struct GetAccountsHomeUseCaseOkOutput {
    let accounts: [AccountEntity]
    let configuration: AccountsHomeConfiguration
    let isCrossSellingEnabled: Bool
    let accountsCrossSelling: [AccountMovementsCrossSellingProperties]
}
