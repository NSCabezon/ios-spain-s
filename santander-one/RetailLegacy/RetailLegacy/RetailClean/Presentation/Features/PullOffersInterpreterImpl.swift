import Foundation
import CoreFoundationLib
import CoreDomain

class PullOffersInterpreterImpl: PullOffersInterpreter {
    
    private var pullOffersRepository: PullOffersRepositoryProtocol
    private let pullOffersEngine: EngineInterface
    private let rulesRepository: RulesRepository
    private let offersRepository: OffersRepository
    private let dependenciesResolver: DependenciesResolver
    private var trackerManager: TrackerManager {
        return dependenciesResolver.resolve()
    }
    
    init(pullOffersRepository: PullOffersRepositoryProtocol, offersRepository: OffersRepository, rulesRepository: RulesRepository, pullOffersEngine: EngineInterface, dependenciesResolver: DependenciesResolver) {
        self.pullOffersRepository = pullOffersRepository
        self.pullOffersEngine = pullOffersEngine
        self.offersRepository = offersRepository
        self.rulesRepository = rulesRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    func reset() {
        pullOffersRepository.visitedLocations.removeAll()
        pullOffersRepository.sessionDisabledOffers.removeAll()
        _ = pullOffersRepository.removePullOffersData()
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        guard let offersIds = category.offers else {
            return nil
        }
        let validOffers: [OfferDTO] = offersIds.compactMap { offerId in
            guard let offer = getOffer(offerId: offerId), validForContract(offer: offer, reload: reload) else {
                return nil
            }
            return offer
        }
        return validOffers.count > 0 ? validOffers: nil
    }
    
    private func trackCandidate(screenId: String?, extraParameters: [String: String]) throws {
        guard let screenId: String = screenId else {
            return
        }
        let eventId: String = TrackerPagePrivate.Generic.Action.seeOffer.rawValue
        trackerManager.trackEvent(screenId: screenId, eventId: eventId, extraParameters: extraParameters)
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        let locationTag: String = location.stringTag
        let response: RepositoryResponse<String> = pullOffersRepository.getOffer(location: locationTag)
        guard
            response.isSuccess(),
            let offerId: String = try? response.getResponseData(),
            let candidate: OfferDTO = getOffer(offerId: offerId)
        else { return nil }
        if !pullOffersRepository.visitedLocations.contains(locationTag) {
            visitOffer(userId: userId, offerDTO: candidate)
            pullOffersRepository.visitedLocations.insert(locationTag)
        }
        try? self.trackCandidate(screenId: location.pageForMetrics, extraParameters: [TrackerDimensions.location: location.stringTag, TrackerDimensions.offerId: offerId])
        return candidate
    }
    
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {
        let locationsWithBanner: Set<String> = PullOffersLocationsFactory().allTagsWithBanner
        for location in locations {
            let offerId = location.value.first { (offerId) -> Bool in
                let hasBanner = locationsWithBanner.contains(location.key)
                return isCandidate(offerId: offerId, reload: reload, userId: userId, hasBanner: hasBanner)
            }
            _ = pullOffersRepository.setOffer(location: location.key, offerId: offerId)
        }
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        let locationsTypeTutorial: [String] = PullOffersLocationsFactory().tutorialPullOffers.map { $0.stringTag }
        return locationsTypeTutorial.contains(location.stringTag) && pullOffersRepository.visitedLocations.contains(location.stringTag)
        return true
    }
    
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        guard let offerId = tip.offerId else {
            return false
        }
        guard let offer = getOffer(offerId: offerId) else {
            return false
        }
        return isValid(offer: offer, reload: reload)
    }
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {
        _ = pullOffersRepository.expireOffer(userId: userId, offerId: offerDTO.product.identifier)
    }
    
    func visitOffer(userId: String, offerDTO: OfferDTO) {
        _ = pullOffersRepository.visitOffer(userId: userId, offerId: offerDTO.product.identifier)
    }
    
    func removeOffer(location: String) {
        _ = pullOffersRepository.removeOffer(location: location)
    }
    
    func disableOffer(identifier: String?) {
        guard let offerId = identifier else { return }
        pullOffersRepository.sessionDisabledOffers.insert(offerId)
    }
    
    func getValidOffer(offerId: String) -> OfferDTO? {
        guard
            let offer = getOffer(offerId: offerId),
            isValid(offer: offer, reload: false)
            else { return nil }
        return offer
    }
    
    func getOffer(offerId: String) -> OfferDTO? {
        guard
            !pullOffersRepository.sessionDisabledOffers.contains(offerId),
            let offers = offersRepository.get()
            else { return nil }
        return offers.first(where: { $0.product.identifier == offerId })
    }
    
    private func validForContract(offer: OfferDTO, reload: Bool) -> Bool {
        let product = offer.product
        guard isValid(offer: offer, reload: reload) else {
            return false
        }
        let contractBanners = getBanners(banners: product.bannersContract)
        if !contractBanners.isEmpty {
            return true
        } else {
            let banners = getBanners(banners: product.banners)
            return !banners.isEmpty
        }
    }
    
    private func isCandidate(offerId: String, reload: Bool, userId: String, hasBanner: Bool) -> Bool {
        guard let offer = getOffer(offerId: offerId) else {
            return false
        }
        let product = offer.product
        guard isValid(offer: offer, reload: reload) else {
            return false
        }
        guard !hasBanner || checkBanners(banners: product.banners) else {
            return false
        }
        guard let offerInfo = getOfferInfo(offerId: product.identifier, userId: userId) else {
            return false
        }
        guard product.neverExpires || !offerInfo.expired else {
            return false
        }
        guard product.iterations == 0 || product.iterations > offerInfo.iterations else {
            return false
        }
        return true
    }
    
    private func verifyDates(offer: OfferDTO) -> Bool {
        let today = Date()
        if let date = offer.product.startDateUTC, today < date {
            return false
        }
        if let date = offer.product.endDateUTC, today > date {
            return false
        }
        return true
    }
    
    private func evaluateRule(ruleId: String) -> Bool {
        guard let rules = rulesRepository.get() else {
            return false
        }
        guard let rule = rules.first(where: { (rule) -> Bool in
            return rule.id == ruleId
        }) else {
            return false
        }
        return pullOffersEngine.isValid(expression: rule.expression)
    }
    
    private func getEvaluatedRule(ruleId: String, reload: Bool) -> Bool {
        if reload {
            return evaluateRule(ruleId: ruleId)
        } else {
            if let isValid = try? pullOffersRepository.isValidRule(identifier: ruleId).getResponseData() {
                return isValid
            } else {
                let isValid = evaluateRule(ruleId: ruleId)
                _ = pullOffersRepository.setRule(identifier: ruleId, isValid: isValid)
                return isValid
            }
        }
    }
        
    private func isValid(offer: OfferDTO, reload: Bool) -> Bool {
        guard verifyDates(offer: offer) else {
            return false
        }
        return offer.product.rulesIds.first(where: { (ruleId) -> Bool in
            return !getEvaluatedRule(ruleId: ruleId, reload: reload)
        }) == nil
    }
    
    private func getOfferInfo(offerId: String, userId: String) -> PullOffersInfoDTO? {
        guard let offerInfo = try? pullOffersRepository.getPullOffersInfo(userId: userId, offerId: offerId).getResponseData() else {
            return nil
        }
        return offerInfo
    }
    
    private func checkBanners(banners: [BannerDTO]) -> Bool {
        return banners.first(where: { (banner) -> Bool in
            return banner.app.contains("ios")
        }) != nil
    }

    private func getBanners(banners: [BannerDTO]) -> [BannerDTO] {
        return banners.filter({ (banner) -> Bool in
            return banner.app.contains("ios")
        })
    }
}
