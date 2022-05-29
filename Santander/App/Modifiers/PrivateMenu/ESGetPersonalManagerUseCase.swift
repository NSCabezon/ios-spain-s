//
//  ESGetPersonalManagerUseCase.swift
//  Santander
//
//  Created by Boris Chirino Fernandez on 15/2/22.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib
import PrivateMenu
import Foundation

struct ESGetPersonalManagerUseCase {
    struct PersonalManagerServiceStatus: PersonalManagerServicesStatusRepresentable {
        var managerWallEnabled: Bool
        var managerWallVersion: Double
        var enableManagerNotifications: Bool
        var videoCallEnabled: Bool
        var videoCallSubtitle: String?
        var userId: String?
    }
    private typealias ManagerState = (stringValues: [String?],
                                      booleanValues: [Bool?],
                                      globalPositionData: GlobalPositionDataRepresentable)
    private let repository: PersonalManagerReactiveRepository
    private let globalpositionRepository: GlobalPositionDataRepository
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let personalManagerNotificationRepository: PersonalManagerNotificationReactiveRepository
    private let appRepository: AppRepositoryProtocol
    private let imageManagerUseCase: GetManagerImageUseCase
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.globalpositionRepository = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
        self.personalManagerNotificationRepository = dependencies.resolve()
        self.appRepository = dependencies.resolve()
        self.imageManagerUseCase = dependencies.resolve()
    }
}

extension ESGetPersonalManagerUseCase: GetPersonalManagerUseCase {
    func fetchPersonalManager() -> AnyPublisher<[PersonalManagerRepresentable], Error> {
       return self.repository.getPersonalManagers()
            .flatMap(getImagesForManagers)
            .map(applyFiltersToManagers)
            .eraseToAnyPublisher()
    }
    
    func fetchServiceStatus() -> AnyPublisher<PersonalManagerServicesStatusRepresentable, Never> {
        return getconfig()
    }

    func unreadNotification() -> AnyPublisher<Bool, Never> {
        return Publishers.Zip(fetchServiceStatus(), getUnreadNotifications())
            .map(buildUnreadStatus)
            .eraseToAnyPublisher()
    }
}

private extension ESGetPersonalManagerUseCase {
    func getconfig() -> AnyPublisher<PersonalManagerServicesStatusRepresentable, Never> {
        let repositoryBoolValues: AnyPublisher<[Bool?], Never> = appConfigRepository
            .values(for: ["enableManagerVideoCall",
                         "enableManagerWall",
                         "enableSidebarManagerNotifications"])
        let repositoryStrValues: AnyPublisher<[String?], Never> =  appConfigRepository
            .values(for: ["managerVideoCallSubtitle",
                          "managerWallVersion"])
        let globalPosition = globalpositionRepository.getGlobalPosition()
        let serviceStatusPublisher = Publishers.Zip3(repositoryStrValues,
                                                     repositoryBoolValues,
                                                     globalPosition)
            .map(createValues)
            .eraseToAnyPublisher()
        return serviceStatusPublisher
    }
    
    private func createValues(result: ManagerState) -> PersonalManagerServicesStatusRepresentable {
        return PersonalManagerServiceStatus(managerWallEnabled: result.booleanValues[0] ?? false,
                                            managerWallVersion: result.stringValues[1]?.stringToDecimal?.doubleValue ?? 0.0,
                                            enableManagerNotifications: result.booleanValues[1] ?? false,
                                            videoCallEnabled: result.booleanValues[2] ?? false,
                                            videoCallSubtitle: result.stringValues[0] ?? "",
                                            userId: result.globalPositionData.userId)
    }
    
    func buildUnreadStatus(input: (mgrStatus: PersonalManagerServicesStatusRepresentable, notifCount: Int)) -> Bool {
        guard input.mgrStatus.managerWallEnabled,
              input.mgrStatus.managerWallVersion == 2,
              input.mgrStatus.enableManagerNotifications,
              input.notifCount > 0 else { return false }
        return true
    }
    
    func getUnreadNotifications() -> AnyPublisher<Int, Never> {
        return personalManagerNotificationRepository
            .getManagerNotificationsInfo()
            .map { notif -> Int in
                guard let url = Int(notif.unreadMessages) else {
                    return 0
                }
                return url
            }
            .replaceError(with: 0)
            .eraseToAnyPublisher()
    }
}

private extension ESGetPersonalManagerUseCase {
    func getImagesForManagers(_ managers: [PersonalManagerRepresentable]) -> AnyPublisher<[PersonalManagerRepresentable], Error> {
        let managersPublishers =  managers.compactMap { manager -> AnyPublisher<PersonalManagerRepresentable, Error> in
            var mutableManager = PersonalManagerItem(representable: manager)
            return imageManagerUseCase.fetchProfileImage(mutableManager.codGest ?? "")
                .flatMap { imageData -> AnyPublisher<PersonalManagerRepresentable, Error>  in
                    mutableManager.thumbnailData = imageData
                    return Just(mutableManager).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                .replaceError(with: mutableManager).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Publishers.MergeMany(managersPublishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func applyFiltersToManagers(_ managers: [PersonalManagerRepresentable]) -> [PersonalManagerRepresentable] {
        let personalManagers = appConfigRepository.getAppConfigListNode("managersSantanderPersonal") ?? []
        let bankManagers = appConfigRepository.getAppConfigListNode("managersBankers") ?? []
        let forbiddenPortfolioTypes = appConfigRepository.getAppConfigListNode("managersNotShow") ?? []
        let filteredManagers = managers.filter { manager in
            guard let portfolioType = manager.portfolioType else { return false }
            return personalManagers.contains(portfolioType) == true || bankManagers.contains(portfolioType) == true
        }
        return filteredManagers.filter { manager in
            guard let portfolioType = manager.portfolioType else { return false }
            return !forbiddenPortfolioTypes.contains(portfolioType)
        }
    }

    struct PersonalManagerItem: PersonalManagerRepresentable {
        let codGest: String?
        let nameGest: String?
        let category: String?
        let portfolio: String?
        let desTipCater: String?
        let phone: String?
        let email: String?
        let indPriority: Int?
        let portfolioType: String?
        var thumbnailData: Data? = nil
        
        init(representable: PersonalManagerRepresentable) {
            codGest = representable.codGest
            nameGest = representable.nameGest
            category = representable.category
            portfolio = representable.portfolio
            desTipCater = representable.desTipCater
            phone = representable.phone
            email = representable.email
            indPriority = representable.indPriority
            portfolioType = representable.portfolioType
        }
    }
}
