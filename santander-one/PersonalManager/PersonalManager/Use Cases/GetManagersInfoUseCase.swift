import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetManagersInfoUseCase: UseCase<Void, GetManagersInfoUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let pullOffersInterpreter: PullOffersInterpreter
    private let managerHobbiesRepository: ManagerHobbiesRepositoryProtocol
    private let appRepository: AppRepositoryProtocol

    private var bankManagers: [ManagerDTO] = []
    private var personalManagers: [ManagerDTO] = []
    private var officeManagers: [ManagerDTO] = []
    private var managersType: [String] = []
    private var managersBankers: [String] = []
    
    private var location: PullOfferLocation {
        return PullOffersLocationsFactoryEntity().manager
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.appConfigRepository = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
        self.managerHobbiesRepository = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetManagersInfoUseCaseOkOutput, StringErrorOutput> {
        let response = try bsanManagersProvider.getBsanManagersManager().getManagers()
        guard response.isSuccess(), let dto = try response.getResponseData() else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId: String = globalPosition.userId else {
            return .error(StringErrorOutput(nil))
        }
        let videoCallEnabled: Bool = appConfigRepository.getBool("enableManagerVideoCall") ?? false
        let managerWallEnabled: Bool = appConfigRepository.getBool("enableManagerWall") ?? false
        managersType = appConfigRepository.getAppConfigListNode("managersSantanderPersonal") ?? []
        managersBankers = appConfigRepository.getAppConfigListNode("managersBankers") ?? []
        let forbiddenPortfolioTypes = appConfigRepository.getAppConfigListNode("managersNotShow") ?? []
        let managers = dto.managerList
            .filter({ $0.portfolioType != nil })
            .filter({ !forbiddenPortfolioTypes.contains($0.portfolioType!) })
        for manager in managers {
            if let portfolioType = manager.portfolioType {
                filterManagers(manager, portfolioType: portfolioType)
            }
        }
        var candidate: (PullOfferLocation, OfferEntity)?
        if let newCandidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
            candidate = (location, OfferEntity(newCandidate, location: location))
        }
        return .ok(
            GetManagersInfoUseCaseOkOutput(
                managerWallEnabled: managerWallEnabled,
                videoCallEnabled: videoCallEnabled,
                userId: userId,
                managerPullOffer: candidate,
                personalManagers: ManagerList(managerListDTO: personalManagers),
                officeManagers: ManagerList(managerListDTO: officeManagers),
                bankManagers: ManagerList(managerListDTO: bankManagers),
                hobbies: try getManagerHobbies()
            )
        )
    }
}

struct GetManagersInfoUseCaseOkOutput {
    let managerWallEnabled: Bool
    let videoCallEnabled: Bool
    let userId: String
    let managerPullOffer: (PullOfferLocation, OfferEntity)?
    let personalManagers: ManagerList
    let officeManagers: ManagerList
    let bankManagers: ManagerList
    let hobbies: [ManagerHobbieEntity]
}

private extension GetManagersInfoUseCase {
    func filterManagers(_ manager: ManagerDTO, portfolioType: String) {
        if managersBankers.contains(portfolioType) {
            bankManagers.append(manager)
        } else if managersType.contains(portfolioType) {
            personalManagers.append(manager)
        } else {
            officeManagers.append(manager)
        }
    }
    
    func getManagerHobbies() throws -> [ManagerHobbieEntity] {
        guard let urlBase = try appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase else { return [] }
        let languageType = try appRepository.getCurrentLanguage()
        managerHobbiesRepository.loadManagerHobbies(baseUrl: urlBase, publicLanguage: languageType.getPublicLanguage)
        guard let dtos = managerHobbiesRepository.getManagerHobbies() else { return [] }
        return ManagerHobbieListEntity(dtos).managerHobbiesEntities
    }
}
