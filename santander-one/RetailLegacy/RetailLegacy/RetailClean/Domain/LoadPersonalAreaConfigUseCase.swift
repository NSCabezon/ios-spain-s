import Foundation
import CoreFoundationLib
import SANLegacyLibrary

struct PersonalAreaConfig {
    let isOTPPushEnabled: Bool
}

class LoadPersonalAreaConfigUseCase: UseCase<Void, LoadPersonalAreaConfigUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadPersonalAreaConfigUseCaseOkOutput, StringErrorOutput> {
        let isOTPPushEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableOtpPush) ?? false
        return .ok(LoadPersonalAreaConfigUseCaseOkOutput(config: PersonalAreaConfig(isOTPPushEnabled: isOTPPushEnabled)))
    }
}

struct LoadPersonalAreaConfigUseCaseOkOutput {
    let config: PersonalAreaConfig
}
