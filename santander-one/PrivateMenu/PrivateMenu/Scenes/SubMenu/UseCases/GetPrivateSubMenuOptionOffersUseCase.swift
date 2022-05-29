//
//  GetPrivateSubMenuFooterOffersUseCase.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 23/3/22.
//
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetPrivateSubMenuOptionOffersUseCase {
    func fetchOffersFor(_ option: PrivateSubMenuOptionType) -> AnyPublisher<[PrivateSubMenuOptions: OfferRepresentable], Never>
}

struct DefaultPrivateSubMenuOptionOffersUseCase: GetPrivateSubMenuOptionOffersUseCase {
    private let offersCandidatesUseCase: GetCandidateOfferUseCase
    private var offersCache = OffersCache()
    
    init(dependencies: PrivateSubMenuDependenciesResolver) {
        offersCandidatesUseCase = dependencies.external.resolve()
    }
    
    func fetchOffersFor(_ option: PrivateSubMenuOptionType) -> AnyPublisher<[PrivateSubMenuOptions: OfferRepresentable], Never> {
        offersCache.setOption(option)
        let result = getCandidates(option.locations)
            .flatMap { offers -> AnyPublisher<[PrivateSubMenuOptions: OfferRepresentable], Never> in
                let offers = offersCache.offersByMenuOptions
                return Just(offers).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        return result
    }
}

private extension DefaultPrivateSubMenuOptionOffersUseCase {
    func getCandidates(_  locations: [PullOfferLocationRepresentable]) -> AnyPublisher<[OfferRepresentable?], Never> {
        let validOffersPublishers = locations.flatMap { location -> AnyPublisher<OfferRepresentable?, Never> in
            return offersCandidatesUseCase.fetchCandidateOfferPublisher(location: location)
                .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never>  in
                    offersCache.storeOffer(offerRepresentable, for: location.stringTag)
                    return Just(offerRepresentable).eraseToAnyPublisher()
                })
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        return Publishers
            .MergeMany(validOffersPublishers)
            .collect(validOffersPublishers.count)
            .eraseToAnyPublisher()
    }
}

extension PrivateSubMenuOptionType {
    var locations: [PullOfferLocationRepresentable] {
        switch self {
        case .myProducts:
            return PullOffersLocationsFactoryEntity().myProducts
        case .sofia:
            return PullOffersLocationsFactoryEntity().investmentSubmenuOffers
        case .world123, .otherServices, .smartServices:
            return []
        }
    }

    var submenuOptions: [PrivateSubMenuOptions] {
        switch self {
        case .myProducts:
            return [
                .sidebarStock,
                .sidebarPensions,
                .sidebarFunds,
                .sidebarInsurance,
                .sidebarDeposits
            ]
        case .sofia:
            return [
                .sidemenuInvestSubsection1,
                .sidemenuInvestSubsection2,
                .sidemenuInvestSubsection3,
                .sidemenuInvestSubsection4,
                .sidemenuInvestSubsection5,
                .sidemenuInvestSubsection6,
                .sidemenuInvestSubsection7,
                .sidemenuInvestSubsection8,
                .menuInvestmentDeposit
            ]
        case .world123, .otherServices, .smartServices:
            return []
        }
    }
}

private extension DefaultPrivateSubMenuOptionOffersUseCase {
    final class OffersCache {
        private var currentOption: PrivateSubMenuOptionType?
        private var offersCache = [String: [OfferRepresentable]]()
        
        func storeOffer(_ offer: OfferRepresentable, for locationTag: String) {
            if offersCache.keys.contains(locationTag) {
                offersCache[locationTag]?.append(offer)
            } else {
                offersCache.updateValue([offer], forKey: locationTag)
            }
        }

        func setOption(_ option: PrivateSubMenuOptionType) {
            self.currentOption = option
        }
        
        var offersByMenuOptions: [PrivateSubMenuOptions: OfferRepresentable] {
            var dictOffers = [PrivateSubMenuOptions: OfferRepresentable]()
            currentOption?.submenuOptions.map { option in
                if let item = offersCache[option.location] {
                    item.map { return dictOffers[option] = $0 }
                }
            }
            return dictOffers
        }
        
        var isCacheWithObjects: Bool {
            return offersCache.values.isNotEmpty
        }
    }
}
