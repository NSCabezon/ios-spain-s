import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetFinanceableConfigurationUseCase: UseCase<Void, GetFinanceableConfigurationUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetFinanceableConfigurationUseCaseOkOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let isSanflixEnabled = appConfigRepository.getBool("enableApplyBySanflix") ?? false
        return .ok(GetFinanceableConfigurationUseCaseOkOutput(isSanflixEnabled: isSanflixEnabled))
    }
}

struct GetFinanceableConfigurationUseCaseOkOutput {
    let isSanflixEnabled: Bool
}
