import Foundation
import CoreFoundationLib

class GetTimeLineIsEnabledUseCase: UseCase<Void, GetTimeLineIsEnabledUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    let appConfig: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: Void)
        throws -> UseCaseResponse<GetTimeLineIsEnabledUseCaseOkOutput, StringErrorOutput> {
            let isTimelineEnabled = self.appConfig.getBool(DomainConstant.appConfigTimelineEnabled) == true
            return .ok(GetTimeLineIsEnabledUseCaseOkOutput(isTimelineEnabled: isTimelineEnabled))
    }
}

struct GetTimeLineIsEnabledUseCaseOkOutput {
    let isTimelineEnabled: Bool
}
