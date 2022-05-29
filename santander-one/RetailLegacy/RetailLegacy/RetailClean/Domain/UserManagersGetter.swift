import SANLegacyLibrary
import CoreFoundationLib

enum UserManagersGetterResult {
    case success(ManagerList)
    case failure(errorMessage: String?)
}

protocol UserManagersGetter {
    var bsanManagersProvider: BSANManagersProvider { get }
    var appConfigRepository: AppConfigRepository { get }
}

extension UserManagersGetter {
    func getManagers() throws -> UserManagersGetterResult {
        let response = try bsanManagersProvider.getBsanManagersManager().getManagers()
        guard response.isSuccess() else {
            return .failure(errorMessage: try response.getErrorMessage())
        }
        let personalManagersIds = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerSantanderPersonal)
        let bankManagersIds = appConfigRepository.getAppConfigListNode(DomainConstant.appConfigManagerSantanderBanker)
        let managersList = try response.getResponseData()
        let filtered: [ManagerDTO] = managersList?.managerList.filter {
            if let portfolioType = $0.portfolioType {
                return personalManagersIds?.contains(portfolioType) == true || bankManagersIds?.contains(portfolioType) == true
            }
            return false
        } ?? []
        
        return .success(ManagerList(managerListDTO: filtered))
    }
}
