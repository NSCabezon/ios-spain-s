import CoreFoundationLib
import SANLegacyLibrary

final class GetSuperSpeedCardsStateUseCase: UseCase<Void, GetSuperSpeedCardsStateUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSuperSpeedCardsStateUseCaseOkOutput, StringErrorOutput> {
        let isSuperSpeedCardEnabled = appConfigRepository.getBool("enableCardSuperSpeed") == true
        return UseCaseResponse.ok(GetSuperSpeedCardsStateUseCaseOkOutput(isSuperSpeedCardEnabled: isSuperSpeedCardEnabled))
    }
}

extension GetSuperSpeedCardsStateUseCase: RepositoriesResolvable {}

struct GetSuperSpeedCardsStateUseCaseOkOutput {
    let isSuperSpeedCardEnabled: Bool
}
