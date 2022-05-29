import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetSanflixUseCase {
    func fetchSanflix() -> AnyPublisher<SanflixContractInfoRepresentable,Never>
}

struct DefaultGetSanflixUseCase {
    private let menuConfigUseCase: GetPrivateMenuConfigUseCase
    private let offers: GetCandidateOfferUseCase
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        menuConfigUseCase = dependencies.resolve()
        offers = dependencies.resolve()
    }
}

extension DefaultGetSanflixUseCase: GetSanflixUseCase {
    func fetchSanflix() -> AnyPublisher<SanflixContractInfoRepresentable, Never> {
        return Publishers.Zip3(isSanflixEnabled, isEnabledExploreProductsInMenu, offer)
            .map(buildSanflix)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetSanflixUseCase {
    struct SanflixInfo: SanflixContractInfoRepresentable {
        let isSanflixEnabled: Bool
        let isEnabledExploreProductsInMenu: Bool
        let offerRepresentable: OfferRepresentable?
    }
    
    func buildSanflix(enabled: Bool,
                      explore: Bool,
                      offer: OfferRepresentable?) -> SanflixContractInfoRepresentable {
        return SanflixInfo(isSanflixEnabled: enabled,
                           isEnabledExploreProductsInMenu: explore,
                           offerRepresentable: offer)
    }
    
    var isSanflixEnabled: AnyPublisher<Bool, Never> {
        return menuConfigUseCase
            .fetchPrivateConfigMenuData()
            .map(\.sanflixEnabled)
            .eraseToAnyPublisher()
    }
    
    var isEnabledExploreProductsInMenu: AnyPublisher<Bool, Never> {
        return menuConfigUseCase
            .fetchPrivateConfigMenuData()
            .map(\.isEnabledExploreProductsInMenu)
            .eraseToAnyPublisher()
    }
    
    var offer: AnyPublisher<OfferRepresentable?, Never> {
        guard let location = PullOffersLocationsFactoryEntity().privateMenuSanflix.first else { return Just(nil).eraseToAnyPublisher() }
        return getCandidate(location)
    }
    
    func getCandidate( _ location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable?, Never> {
        return offers.fetchCandidateOfferPublisher(location: location)
            .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never> in
                return Just(offerRepresentable).eraseToAnyPublisher()
            })
            .replaceError(with: nil)
            .map {$0}
            .eraseToAnyPublisher()
    }
}
