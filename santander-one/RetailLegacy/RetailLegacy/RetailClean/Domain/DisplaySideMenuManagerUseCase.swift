import CoreFoundationLib
import SANLegacyLibrary

class DisplaySideMenuManagerUseCase: UseCase<DisplaySideMenuManagerUseCaseInput, DisplaySideMenuManagerOkOutput, StringErrorOutput> {
    
    private let appRepository: AppRepository
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfig: AppConfigRepository
    
    init(appRepository: AppRepository, appConfig: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appRepository = appRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfig = appConfig
    }
    
    override public func executeUseCase(requestValues: DisplaySideMenuManagerUseCaseInput) throws -> UseCaseResponse<DisplaySideMenuManagerOkOutput, StringErrorOutput> {
        let isCoachmarkManagerEnabled = appConfig.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigManagerSideMenuCoachmark) ?? false
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let wasDisplayedBefore = try appRepository.isCoachmarkShown(coachmarkId: requestValues.coachmarkId, userId: userId).getResponseData() ?? false
        
        return UseCaseResponse.ok(DisplaySideMenuManagerOkOutput(wasDisplayedBefore: wasDisplayedBefore, isCoachmarkManagerEnabled: isCoachmarkManagerEnabled))
    }
}

struct DisplaySideMenuManagerUseCaseInput {
    let coachmarkId: CoachmarkIdentifier
}

struct DisplaySideMenuManagerOkOutput {
    let wasDisplayedBefore: Bool
    let isCoachmarkManagerEnabled: Bool
}
