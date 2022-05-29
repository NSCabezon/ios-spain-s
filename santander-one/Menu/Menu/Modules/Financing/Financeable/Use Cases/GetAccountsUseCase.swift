import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public final class GetAccountsUseCase: UseCase<Void, GetAccountsUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAccountsUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isAccountEasyPayEnabled = appConfigRepository.getBool(AccountsConstants.appConfigEnableAccountEasyPayForBills) ?? false
        let isAccountFinancingEnabled = appConfigRepository.getBool(AccountsConstants.appConfigEnableAccountFinancingMovements) ?? false
        guard isAccountEasyPayEnabled && isAccountFinancingEnabled else {
            return .error(StringErrorOutput(nil))
        }
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accountList = globalPosition.accountsVisiblesWithoutPiggy
            .filter({ $0.isAccountHolder() })
            .sorted(by: { ($0.alias ?? "").lowercased() < ($1.alias ?? "").lowercased() })
        
        return .ok(GetAccountsUseCaseOkOutput(accountList: accountList))
    }
}

public struct GetAccountsUseCaseOkOutput {
    let accountList: [AccountEntity]
}
