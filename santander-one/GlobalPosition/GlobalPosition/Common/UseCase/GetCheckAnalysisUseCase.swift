import CoreFoundationLib
import Foundation

final class GetCheckAnalysisUseCase: UseCase<Void, GetCheckAnalysisUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetCheckAnalysisUseCaseOkOutput, StringErrorOutput> {
        let appconfigRepository: AppConfigRepositoryProtocol = self.dependenciesResolver.resolve()
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let visibleAnalysisZoneFromAppConfig = appconfigRepository.getBool("enabledAnalysisZone") ?? false
        let visibleProduct = globalPosition.accounts.visibles().count > 0 || globalPosition.cards.visibles().count > 0
        let visibleZone = visibleAnalysisZoneFromAppConfig && visibleProduct
        return .ok(GetCheckAnalysisUseCaseOkOutput(visibleAnalysisZone: visibleZone))
    }
}

struct GetCheckAnalysisUseCaseOkOutput {
    let visibleAnalysisZone: Bool
}
