import CoreFoundationLib
import SANLegacyLibrary

class IsMarketplaceEnabledUseCase: UseCase<Void, IsMarketplaceEnabledUseCaseOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<IsMarketplaceEnabledUseCaseOkOutput, StringErrorOutput> {
        let isEnabled: Bool? = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigIsMarketplaceEnabled)
        return UseCaseResponse.ok(IsMarketplaceEnabledUseCaseOkOutput(isEnabled: isEnabled ?? false))
    }
}

struct IsMarketplaceEnabledUseCaseOkOutput {
    let isEnabled: Bool
}
