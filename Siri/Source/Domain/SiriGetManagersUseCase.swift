import CoreFoundationLib
import SANLibraryV3
import RetailLegacy

class SiriGetManagersUseCase: UseCase<Void, SiriGetManagersUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    private let daoSharedAppConfig: DAOSharedAppConfig
    
    init(bsanManagersProvider: BSANManagersProvider, daoSharedAppConfig: DAOSharedAppConfig) {
        self.bsanManagersProvider = bsanManagersProvider
        self.daoSharedAppConfig = daoSharedAppConfig
        super.init()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SiriGetManagersUseCaseOkOutput, StringErrorOutput> {
        let response = try bsanManagersProvider.getBsanManagersManager().loadManagers()
        guard response.isSuccess() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let managersType = daoSharedAppConfig.get().managersSantanderPersonal
        let managersList = try response.getResponseData()
        let filtered: [ManagerDTO] = managersList?.managerList.filter {
            if let portfolioType = $0.portfolioType {
                return managersType?.contains(portfolioType) == true
            }
            return false
            } ?? []
        
        return UseCaseResponse.ok(SiriGetManagersUseCaseOkOutput(managers: ManagerList(managerListDTO: filtered)))
    }
}

struct SiriGetManagersUseCaseOkOutput {
    let managers: ManagerList
}
