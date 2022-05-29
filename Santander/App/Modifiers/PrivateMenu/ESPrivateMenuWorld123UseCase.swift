import PrivateMenu
import OpenCombine
import CoreDomain
import CoreFoundationLib

struct ESPrivateMenuWorld123UseCase: GetWorld123SubMenuUseCase {
    private let offers: GetCandidateOfferUseCase
    
    init(dependencies: PrivateMenuModuleExternalDependenciesResolver) {
        offers = dependencies.resolve()
    }
    
    func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return world123
    }
}

private extension ESPrivateMenuWorld123UseCase {
    var world123: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        let mundoSimulate = isLocation("MUNDO123_MENU_SIMULATE")
            .map { value -> PrivateSubmenuAction in .worldOffer(.mundoSimulate, value) }
        let mundoWhatHave = isLocation("MUNDO123_MENU_WHATHAVE")
            .map { value -> PrivateSubmenuAction in .worldOffer(.mundoWhatHave, value) }
        let mundoBenefits = isLocation("MUNDO123_MENU_BENEFITS")
            .map { value -> PrivateSubmenuAction in .worldOffer(.mundoBenefits, value) }
        let mundoSignUp = isLocation("MUNDO123_MENU_SIGNUP")
            .map { value -> PrivateSubmenuAction in .worldOffer(.mundoSignUp, value) }
        var options: [PrivateSubmenuAction] = []
        return Publishers
            .Zip4(mundoSimulate,
                  mundoWhatHave,
                  mundoBenefits,
                  mundoSignUp)
            .compactMap { action in
                options.append(action.0)
                options.append(action.1)
                options.append(action.2)
                options.append(action.3)
                return options
            }
            .map(buildOptions)
            .eraseToAnyPublisher()
    }
    
    func buildOptions(_ options: [PrivateSubmenuAction]) -> [PrivateMenuSectionRepresentable] {
        return [PrivateMenuSection(items: options.toOptionRepresentable())]
    }
    
    var world123SideMenu: [PullOfferLocationRepresentable] {
        return PullOffersLocationsFactoryEntity().world123SideMenu
    }
    
    func isLocation(_ location: String) -> AnyPublisher<OfferRepresentable?, Never> {
        guard let location = PullOffersLocationsFactoryEntity()
                .getLocationRepresentable(locations: world123SideMenu, location: location) else {
                    return Just(nil).eraseToAnyPublisher() }
        return getCandidate(location).eraseToAnyPublisher()
    }
    
    func getCandidate( _ location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable?, Never> {
        return offers.fetchCandidateOfferPublisher(location: location)
            .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never> in
                return Just(offerRepresentable).eraseToAnyPublisher()
            })
            .replaceError(with: nil)
            .map { $0 }
            .eraseToAnyPublisher()
    }
}
