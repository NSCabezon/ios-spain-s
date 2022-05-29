import OpenCombine
import PrivateMenu
import CoreDomain
import CoreFoundationLib

struct ESPrivateMenuOtherServicesUseCase: GetOtherServicesSubMenuUseCase {
    private let offers: GetCandidateOfferUseCase
    private let appConfig: AppConfigRepositoryProtocol
    private let globalPositionRepository: GlobalPositionDataRepository
    private let userPrefRepository: UserPreferencesRepository
    private let servicesForYou: ServicesForYouRepository
    
    init(dependencies: PrivateMenuModuleExternalDependenciesResolver) {
        offers = dependencies.resolve()
        appConfig = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
        userPrefRepository = dependencies.resolve()
        servicesForYou = ServicesForYouRepository(
            netClient: NetClientImplementation(),
            assetsClient: AssetsClient())
    }
    
    func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return otherServices
    }
}

private extension ESPrivateMenuOtherServicesUseCase {
    var otherServices: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        let enableComingFeatures = appConfig
            .value(for: "enableComingFeatures", defaultValue: false)
        let location = PullOffersLocationsFactoryEntity().privateMenuCarbonFootPrint.first
        let carbonFinger = getCandidate(location)
        return enableComingFeatures
            .zip(carbonFinger, isSmartServicesEnabled) { features, carbon, smart -> [PrivateMenuSectionRepresentable] in
                var options: [PrivateSubmenuAction] = []
                if features {
                    options.append(.otherOffer(.next))
                }
                if let carbon = carbon {
                    options.append(.otherOffer(.carbonFingerPrint, carbon))
                }
                if smart {
                    options.append(.otherOffer(.smartServices))
                }
                let allOptions = PrivateMenuSection(items: options.toOptionRepresentable())
                return [allOptions]
            }
            .eraseToAnyPublisher()
    }
    
    var isSmartServicesEnabled: AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.userId)
            .flatMap { userId -> AnyPublisher<String, Error> in
                guard let userId = userId else { return Fail(error: NSError(description: "no-user-id")).eraseToAnyPublisher() }
                return Just(userId).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .map(userPrefRepository.getUserPreferences)
            .flatMap { $0 }
            .map { userPref in
                let smartServices = servicesForYou.get()
                let categoriesNotEmpty = smartServices?.categoriesRepresentable.isNotEmpty ?? false
                return userPref.isSmartUser() && categoriesNotEmpty
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    func getCandidate( _ location: PullOfferLocationRepresentable?) -> AnyPublisher<OfferRepresentable?, Never> {
        guard let location = location else { return Just(nil).eraseToAnyPublisher() }
        return offers.fetchCandidateOfferPublisher(location: location)
            .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never> in
                return Just(offerRepresentable).eraseToAnyPublisher()
            })
            .replaceError(with: nil)
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
