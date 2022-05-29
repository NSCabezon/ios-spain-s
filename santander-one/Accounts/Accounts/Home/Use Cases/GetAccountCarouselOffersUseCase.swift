//
//  GetAccountCarouselOffersUseCase.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 28/7/21.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

private extension GetAccountCarouselOffersUseCase {
    enum Constants {
        static let enableAccountOfferCarousel = "enableAccountOfferCarousel"
        static let pregrantedBannerColor = "pgTopPregrantedBannerColor"
        static let pregrantedBannerText = "pgTopPregrantedBannerText"
        static let pregrantedBannerStartedText = "pregrantedBannerStartedText"
        static let pGTopPregrantedBannerEnable = "enablePGTopPregrantedBanner"
        static let robinsonUser = "2"
    }
}

class GetAccountCarouselOffersUseCase: UseCase<GetAccountCarouselOffersUseCaseInput, GetAccountCarouselOffersUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let localAppConfig: LocalAppConfig
    private let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol
    private let pullOffersInterpreter: PullOffersInterpreter

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigRepository = dependenciesResolver.resolve()
        self.localAppConfig = dependenciesResolver.resolve()
        self.pullOffersConfigRepository = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: GetAccountCarouselOffersUseCaseInput) throws -> UseCaseResponse<GetAccountCarouselOffersUseCaseOkOutput, StringErrorOutput> {
        let isAccountOfferCarouselEnabled = self.appConfigRepository.getBool(Constants.enableAccountOfferCarousel) ?? false && self.localAppConfig.isEnabledPregranted
        let isPGTopPregrantedBannerEnable = appConfigRepository.getBool(Constants.pGTopPregrantedBannerEnable) ?? false && self.localAppConfig.isEnabledPregranted
        let pregrantedBannerColor = self.appConfigRepository.getString(Constants.pregrantedBannerColor) ?? ""
        let pregrantedBannerText = self.appConfigRepository.getString(Constants.pregrantedBannerText) ?? ""
        let pregrantedBannerStartedText = self.appConfigRepository.getString(Constants.pregrantedBannerStartedText) ?? ""
        let accountTopOffers = self.getAccountTopOffers()
        var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve()
        if let userId = globalPosition.userId {
            for location in requestValues.locations {
                if let candidate = self.pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    pullOfferCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        let bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let userCampaigns = try (bsanManagersProvider.getBsanPullOffersManager().getCampaigns().getResponseData()) ?? []
        // RobinsonUser
        let isRobinsonUser = userCampaigns?
            .filter({ $0 == Constants.robinsonUser })
            .first != nil
        let output: GetAccountCarouselOffersUseCaseOkOutput = GetAccountCarouselOffersUseCaseOkOutput(
            isAccountOfferCarouselEnabled: isAccountOfferCarouselEnabled,
            isPGTopPregrantedBannerEnable: isPGTopPregrantedBannerEnable,
            pregrantedBannerColor: pregrantedBannerColor,
            pregrantedBannerText: pregrantedBannerText,
            pregrantedBannerStartedText: pregrantedBannerStartedText,
            accountTopOffers: accountTopOffers,
            pullOfferCandidates: pullOfferCandidates,
            isRobinsonUser: isRobinsonUser
        )
        return .ok(output)
    }

}

private extension GetAccountCarouselOffersUseCase {
    func getAccountTopOffers() -> [ExpirableOfferEntity] {
        let accountCarouselCandidates: [ExpirableOfferEntity] = (self.pullOffersConfigRepository.getAccountTopOffers() ?? [])
            .lazy
            .sorted(by: { return $0.priority < $1.priority })
            .compactMap { (offer) in
                guard let validOffer = self.pullOffersInterpreter.getValidOffer(offerId: offer.id) else { return nil }
                return ExpirableOfferEntity(validOffer,
                                            location: PullOfferLocation(stringTag: "", hasBanner: false, pageForMetrics: nil),
                                            expiresOnClick: offer.expireOnClick)
            }
        return accountCarouselCandidates
    }
}

struct GetAccountCarouselOffersUseCaseInput {
    let locations: [PullOfferLocation]
}

struct GetAccountCarouselOffersUseCaseOkOutput {
    let isAccountOfferCarouselEnabled: Bool
    let isPGTopPregrantedBannerEnable: Bool
    let pregrantedBannerColor: String
    let pregrantedBannerText: String
    let pregrantedBannerStartedText: String
    let accountTopOffers: [ExpirableOfferEntity]?
    let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    let isRobinsonUser: Bool
}
