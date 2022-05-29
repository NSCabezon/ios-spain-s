import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

protocol GetPublicMenuOffersUseCase {
    func publicMenuValidOffers() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never>
}

struct DefaultGetPublicMenuOffersUseCase {
    private let pullOfferRepository: ReactivePullOffersConfigRepository
    private let interpreterReactive: ReactivePullOffersInterpreter
    private let baseURLProvider: BaseURLProvider
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.pullOfferRepository = dependencies.external.resolve()
        self.interpreterReactive = dependencies.external.resolve()
        self.baseURLProvider = dependencies.external.resolve()
    }
}

extension DefaultGetPublicMenuOffersUseCase: GetPublicMenuOffersUseCase {
    func publicMenuValidOffers() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        pullOfferRepository
            .getPublicCarouselOffers()
            .flatMap(validOffersPublisher)
            .catch { _ in
                return Just([]).eraseToAnyPublisher()
            }
            .map({ completedOffers in
                let elems = completedOffers.map { (offer, tip) in
                    PublicOfferElement(offerTip: tip, validOffer: offer, baseURL: baseURLProvider.baseURL)
                }
                return [[PublicMenuElem(top: PublicMenuOfferOption(offers: elems),
                                        bottom: nil)]]
            })
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetPublicMenuOffersUseCase {
    
    typealias CompleteOffer = (OfferRepresentable, PullOfferTipRepresentable)
    
    func validOffersPublisher(_ offers: [PullOfferTipRepresentable]) -> AnyPublisher<[CompleteOffer], Error> {
        let validOffersPublishers = offers.compactMap { offer -> AnyPublisher<CompleteOffer, Error>? in
            guard let offerId = offer.offerId else { return nil }
            return interpreterReactive.getValidOffer(offerId: offerId)
                .map { result in
                    CompleteOffer(result, offer)
                }
                .eraseToAnyPublisher()
        }
        return Publishers
            .MergeMany(validOffersPublishers)
            .collect()
            .eraseToAnyPublisher()
    }
    
    struct PublicMenuElem: PublicMenuElementRepresentable {
        var top: PublicMenuOptionRepresentable?
        var bottom: PublicMenuOptionRepresentable?
    }
    
    struct PublicMenuOfferOption: PublicMenuOptionRepresentable {
        var kindOfNode: KindOfPublicMenuNode
        var titleKey: String
        var iconKey: String
        var action: PublicMenuAction
        var event: String
        var accessibilityIdentifier: String?
        var type: PublicMenuOptionType
        
        init?(offers: [PublicOfferElementRepresentable]) {
            guard offers.count > 0 else { return nil }
            self.kindOfNode = .none
            self.titleKey = ""
            self.iconKey = ""
            self.action = .none
            self.event = PublicMenuPage.Action.offer.rawValue
            self.accessibilityIdentifier = "PublicOfferCarrouselView"
            self.type = .publicOffer(items: offers)
        }
    }
    
    struct PublicOfferElement: PublicOfferElementRepresentable {
        var titleKey: String
        var imageURL: String
        var description: String?
        var offerId: String?
        var tag: String?
        var offerRepresentable: OfferRepresentable?
        var keyWords: [String]?
        
        init(offerTip: PullOfferTipRepresentable, validOffer: OfferRepresentable, baseURL: String?) {
            self.titleKey = offerTip.title ?? ""
            self.imageURL = (baseURL ?? "").dropLast(1) + (offerTip.icon ?? "")
            self.description = offerTip.description
            self.offerId = offerTip.offerId
            self.tag = offerTip.tag
            self.offerRepresentable = validOffer
            self.keyWords = offerTip.keyWords
        }
    }
}
