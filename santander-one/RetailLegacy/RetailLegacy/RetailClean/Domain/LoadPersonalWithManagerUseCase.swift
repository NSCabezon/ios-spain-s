import CoreFoundationLib
import SANLegacyLibrary

class LoadPersonalWithManagerUseCase: UseCase<Void, LoadPersonalWithManagerUseCaseOkOutput, StringErrorOutput> {
    let bsanManagersProvider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    
    init(bsanManagersProvider: BSANManagersProvider, appConfig: AppConfigRepository) {
        self.bsanManagersProvider = bsanManagersProvider
        appConfigRepository = appConfig
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<LoadPersonalWithManagerUseCaseOkOutput, StringErrorOutput> {
        let gPositionDTO = try checkRepositoryResponse(bsanManagersProvider.getBsanPGManager().getGlobalPosition())
        let user = UserDO(dto: gPositionDTO?.userDataDTO)
        guard let userId = user.userId else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let videoCallEnabled: Bool = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableManagerVideoCall) ?? false
        let videoCallSubtitle: String? = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigManagerVideoCallSubtitle)
        let managerWallEnabled: Bool = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableManagerWall) ?? false
        let managerWallVersion = (appConfigRepository.getAppConfigDecimalNode(nodeName: DomainConstant.appConfigManagerWallVersion) ?? 0.0)
        let enableSidebarManagerNotifications = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigManagerSidebarManagerNotifications) ?? false
        
        return UseCaseResponse.ok(LoadPersonalWithManagerUseCaseOkOutput(managerWallEnabled: managerWallEnabled,
                                                                         managerWallVersion: (managerWallVersion as NSDecimalNumber).intValue,
                                                                         enableManagerNotifications: enableSidebarManagerNotifications,
                                                                         videoCallEnabled: videoCallEnabled,
                                                                         videoCallSubtitle: videoCallSubtitle,
                                                                         userId: userId))
    }
}

struct LoadPersonalWithManagerUseCaseOkOutput {
    let managerWallEnabled: Bool
    let managerWallVersion: Int
    let enableManagerNotifications: Bool
    let videoCallEnabled: Bool
    let videoCallSubtitle: String?
    let userId: String
}
