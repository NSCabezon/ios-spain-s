import SANLegacyLibrary
import CoreFoundationLib


class PreSetupEnableOtpPushUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    
    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let appConfigEnableOtpPush = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableOtpPush)
        return appConfigEnableOtpPush == true ? .ok(): .error(StringErrorOutput(nil))
    }
}
