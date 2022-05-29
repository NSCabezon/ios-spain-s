import Foundation
import PrivateMenu
import OpenCombine
import CoreDomain
import CoreFoundationLib

struct PrivateMenuSection: PrivateMenuSectionRepresentable {
    let titleKey: String?
    let items: [PrivateSubMenuOptionRepresentable]
    
    public init(titleKey: String? = nil, items: [PrivateSubMenuOptionRepresentable]) {
        self.titleKey = titleKey
        self.items = items
    }
}

struct SubMenuElement: CoreDomain.PrivateSubMenuOptionRepresentable {
    let titleKey: String
    let icon: String?
    let submenuArrow: Bool
    let elementsCount: Int?
    let action: PrivateSubmenuAction
}

struct ESPrivateMenuMyProductsUseCase: GetMyProductSubMenuUseCase {
    private let boxes: GetMyProductsUseCase
    private let globalPositionRepository: GlobalPositionDataRepository
    private let offers: GetCandidateOfferUseCase
    private let pullOfferInterpreterReactive: ReactivePullOffersInterpreter
    // NOTE: pension and fund pending on localAppConfig by country, remove where not necessary !!!
    private let dictOptions: [PrivateSubmenuAction: UserPrefBoxType] =
    [
        PrivateSubmenuAction.myProductOffer(.accounts): UserPrefBoxType.account,
        PrivateSubmenuAction.myProductOffer(.cards): UserPrefBoxType.card,
        PrivateSubmenuAction.myProductOffer(.stocks): UserPrefBoxType.stock,
        PrivateSubmenuAction.myProductOffer(.loans): UserPrefBoxType.loan,
        PrivateSubmenuAction.myProductOffer(.deposits): UserPrefBoxType.deposit,
        PrivateSubmenuAction.myProductOffer(.pensions): UserPrefBoxType.pension,
        PrivateSubmenuAction.myProductOffer(.funds): UserPrefBoxType.fund,
        PrivateSubmenuAction.myProductOffer(.insuranceSavings): UserPrefBoxType.insuranceSaving,
        PrivateSubmenuAction.myProductOffer(.insuranceProtection): UserPrefBoxType.insuranceProtection
    ]
    
    init(dependencies: PrivateMenuModuleExternalDependenciesResolver) {
        boxes = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
        offers = dependencies.resolve()
        pullOfferInterpreterReactive = dependencies.resolve()
    }
    
    func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return finalOptions
    }
}

private extension ESPrivateMenuMyProductsUseCase {
    var finalOptions: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return Publishers.Zip3(
            optionsMyProducts,
            boxes.fetchMyProducts().replaceError(with: [:]),
            globalPositionRepository.getGlobalPosition())
            .map(buildOptions)
            .eraseToAnyPublisher()
    }
    
    var isPb: AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.isPb)
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    var optionsMyProducts: AnyPublisher<[PrivateSubmenuAction], Never> {
        return isPb
            .map { return $0 ? PrivateMenuMyProductsOption.actionPbOrder : PrivateMenuMyProductsOption.actionNotPbOrder }
            .zip(isTPVLocations) { previous, tpv in
                var final: [PrivateSubmenuAction] = []
                final.append(contentsOf: previous)
                if let tpv = tpv {
                    final.append(.myProductOffer(.tpvs, tpv))
                }
                return final
            }
            .eraseToAnyPublisher()
    }
    
    var isTPVLocations: AnyPublisher<OfferRepresentable?, Never> {
        return isLocation("MENU_TPV")
    }
    
    func buildOptions(_ options: [PrivateSubmenuAction],
                       _ boxes: [UserPrefBoxType: PGBoxRepresentable],
                       _ globalPosition: GlobalPositionDataRepresentable) -> [PrivateMenuSectionRepresentable] {
        let finalOptions = options.filter { option in
            if let boxOption = dictOptions[option] {
                return boxes.keys.contains(boxOption)
            }
            if case let .myProductOffer(_, offer) = option {
                return offer != nil
            }
            return false
        }
        let countedElements = howManyElementsIn(boxes: boxes, from: finalOptions)
        let section = PrivateMenuSection(items: finalOptions.toOptionRepresentable(countedElements))
        return [section]
    }
    
    func isLocation(_ location: String) -> AnyPublisher<OfferRepresentable?, Never> {
        guard let location = PullOffersLocationsFactoryEntity()
                .getLocationRepresentable(
                    locations: PullOffersLocationsFactoryEntity().myProductsSideMenu,
                    location: location) else {
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

extension Array where Element == PrivateSubmenuAction {
    
    func toOptionRepresentable(_ elementsCount: [PrivateSubmenuAction: Int]? = nil) -> [PrivateSubMenuOptionRepresentable] {
        var result = [PrivateSubMenuOptionRepresentable]()
        self.forEach { option in
            switch option {
            case .myProductOffer(let product, _):
                guard let elementsCount = elementsCount else { return }
                let item = SubMenuElement(titleKey: product.titleKey,
                                          icon: product.imageKey,
                                          submenuArrow: false,
                                          elementsCount: elementsCount[option],
                                          action: option)
                result.append(item)
            case .sofiaOffer(let sofia, _):
                guard let elementsCount = elementsCount else { return }
                let item = SubMenuElement(titleKey: sofia.titleKey,
                                          icon: sofia.icon,
                                          submenuArrow: false,
                                          elementsCount: elementsCount[option],
                                          action: option)
                result.append(item)
            case .otherOffer(let other, _):
                let item = SubMenuElement(titleKey: other.titleKey,
                                          icon: other.icon,
                                          submenuArrow: false,
                                          elementsCount: nil,
                                          action: option)
                result.append(item)
            case .worldOffer(let world, _):
                let item = SubMenuElement(titleKey: world.titleKey,
                                          icon: world.imageKey,
                                          submenuArrow: false,
                                          elementsCount: nil,
                                          action: option)
                result.append(item)
            }
        }
        return result
    }
}

private extension ESPrivateMenuMyProductsUseCase {
    func howManyElementsIn(boxes: [UserPrefBoxType: PGBoxRepresentable],
                           from myProducts: [PrivateSubmenuAction]) -> [PrivateSubmenuAction: Int] {
        var result = [PrivateSubmenuAction: Int]()
        myProducts.forEach { option in
            result.updateValue(countForOption(option: option, in: boxes), forKey: option)
        }
        return result
    }
    
    func countForOption(option: PrivateSubmenuAction, in boxes: [UserPrefBoxType: PGBoxRepresentable]) -> Int {
        guard let userPrefBox = dictOptions[option],
              let boxRepresentable = boxes[userPrefBox]
        else { return 0 }
        return boxRepresentable.productsRepresentable.count
    }
}

extension PrivateMenuSubmenuFooterOffer {
    func offers() -> [PullOfferLocationRepresentable] {
        switch self {
        case .myProducts:
            return PullOffersLocationsFactoryEntity().myProducts
        case .investments:
            return PullOffersLocationsFactoryEntity().investmentSubmenuOffers
        }
    }
}
