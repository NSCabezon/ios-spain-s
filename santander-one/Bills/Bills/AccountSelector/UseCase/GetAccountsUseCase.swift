import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetAccountsUseCase: UseCase<Void, GetAccountsUseCaseOkOutput, StringErrorOutput> {
    let dependencies: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAccountsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable =
            dependencies.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let accounts = globalPosition.accountsVisiblesWithoutPiggy
        let response = GetAccountsUseCaseOkOutput(accounts: accounts)
        return .ok(response)
    }
}

struct GetAccountsUseCaseOkOutput {
    let accounts: [AccountEntity]
}
