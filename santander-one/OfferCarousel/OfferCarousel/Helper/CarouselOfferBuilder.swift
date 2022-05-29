//
//  OfferCarouselBuilder.swift
//  OfferCarousel
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation
import CoreFoundationLib

public protocol OfferCarouselBuilderDelegate {
    func isPregrantedOfferExpired(_ offerId: String) -> Bool
}

public protocol OfferCarouselBuilderProtocol {
    func build(pregrantedConfiguration: PregrantedConfiguration,
               shouldDisplayRobinsonBanner: Bool,
               carouselOfferViewModels: [CarouselOfferViewModel],
               pullOfferCandidates: [PullOfferLocation: OfferEntity])
    func createOfferCarouselCells() -> OfferCarouselViewModel?
    func isPregrantedOfferExpired(_ offerId: String) -> Bool
    func setPregrantedViewModel(pregrantedViewModel: PregrantedViewModel?)
    func setPregrantedOfferEntity(pregrantedOfferEntity: OfferEntity?)
    func setPregrantedBanner(display: Bool)
}

public final class OfferCarouselBuilder: OfferCarouselBuilderProtocol {
    public func setPregrantedBanner(display: Bool) {
        userHasPreconceived = display
    }
    
    
    // MARK: - Attributes
    
    var pregrantedOfferEntity: OfferEntity?
    var pregrantedViewModel: PregrantedViewModel?
    private var pregrantedConfiguration: PregrantedConfiguration?
    private var carouselOfferViewModels: [CarouselOfferViewModel] = []
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    private var shouldDisplayRobinsonBanner = false
    private var userHasPreconceived = false
    
    // MARK: - Initializers
    
    public init() {}

    // MARK: - Public methods
    
    public func build(
        pregrantedConfiguration: PregrantedConfiguration,
        shouldDisplayRobinsonBanner: Bool,
        carouselOfferViewModels: [CarouselOfferViewModel],
        pullOfferCandidates: [PullOfferLocation: OfferEntity]
    ) {
        self.pregrantedConfiguration = pregrantedConfiguration
        self.shouldDisplayRobinsonBanner = shouldDisplayRobinsonBanner
        self.carouselOfferViewModels = carouselOfferViewModels
        self.pullOfferCandidates = pullOfferCandidates
    }
    
    public func createOfferCarouselCells() -> OfferCarouselViewModel? {
        guard
            let pregrantedConfiguration = self.pregrantedConfiguration,
            pregrantedConfiguration.isVisible
        else {
            return nil
        }
        let filteredCarouselOffers = self.getFilteredCarouselOffers()
        let elems: [OfferCarouselViewModelType] = filteredCarouselOffers.compactMap { (offer) in
            guard (offer.elem as? OfferEntity)?.id == GlobalPositionPullOffers.pgTopPregrantedOfferId ||
                  ((offer.elem as? OfferEntity)?.id == GlobalPositionPullOffers.pgTopPregrantedRobinsonOfferId && shouldDisplayRobinsonBanner)
            else { return OfferCarouselViewModelType.offer(offer) }
            if let viewModel = self.pregrantedViewModel,
               let expirableOffer = offer.elem as? ExpirableOfferEntity {
                let loanExpirableOffer = ExpirableOfferEntity(viewModel.offerEntity.dto,
                                                              location: viewModel.offerLocation,
                                                              expiresOnClick: expirableOffer.expiresOnClick)
                let color = pregrantedConfiguration.pregrantedBannerColor
                let pregrantedStartedUnwrapped = (pregrantedConfiguration.pgTopPregrantedBannerStartedText)
                let pregrantedStartedText = (pregrantedStartedUnwrapped.isEmpty ?
                                                color.pregrantedStartedDefaultTitleKey() : pregrantedStartedUnwrapped)
                let pregrantedText = (viewModel.isPregrantedProcessInProgress ?
                                        pregrantedStartedText : pregrantedConfiguration.pregrantedBannerText)
                let pregranted = PregrantedBannerViewModel(amount: viewModel.amountMaximum,
                                                             expirableOfferEntity: loanExpirableOffer,
                                                             pregrantedBannerColor: color,
                                                             pregrantedBannerText: pregrantedText)
                return OfferCarouselViewModelType.pregranted(pregranted)
            } else if shouldDisplayRobinsonBanner && userHasPreconceived,
               (offer.elem as? OfferEntity)?.id == GlobalPositionPullOffers.pgTopPregrantedRobinsonOfferId {
                return OfferCarouselViewModelType.offer(offer)
            }
            return nil
        }
        guard !elems.isEmpty else { return nil }
        return OfferCarouselViewModel(elements: elems)
    }
    
    public func isPregrantedOfferExpired(_ offerId: String) -> Bool {
        let pregrantedOfferId = self.pregrantedOfferEntity?.id == offerId ? GlobalPositionPullOffers.pgTopPregrantedOfferId : offerId
        self.carouselOfferViewModels = self.getFilteredCarouselOffers().filter {
            return ($0.elem as? ExpirableOfferEntity)?.id != pregrantedOfferId
        }
        return self.carouselOfferViewModels.isEmpty
    }

    public func setPregrantedViewModel(pregrantedViewModel: PregrantedViewModel?) {
        self.pregrantedViewModel = pregrantedViewModel
    }
    
    public func setPregrantedOfferEntity(pregrantedOfferEntity: OfferEntity?) {
        self.pregrantedOfferEntity = pregrantedOfferEntity
    }
}

private extension OfferCarouselBuilder {
    func getFilteredCarouselOffers() -> [CarouselOfferViewModel] {
        guard let pregrantedConfiguration = self.pregrantedConfiguration else {
            return []
        }
        let currentOffersFilter = self.carouselOfferViewModels.filter {
            guard let offer = ($0.elem as? OfferEntity),
                  offer.id == GlobalPositionPullOffers.pgTopPregrantedOfferId
            else { return true }
            if pregrantedConfiguration.isPGTopPregrantedBannerEnable == true,
               self.pullOfferCandidates.contains(location: GlobalPositionPullOffers.loansSimulator),
               self.pregrantedViewModel != nil {
                return true
            }
            return false
        }
        if shouldDisplayRobinsonBanner && userHasPreconceived {
            let updatedCarouselOfferItems = currentOffersFilter.filter {
                ($0.elem as? OfferEntity)?.id != GlobalPositionPullOffers.pgTopPregrantedOfferId
            }
            return updatedCarouselOfferItems
        } else {
            let updatedCarouselOfferItems = currentOffersFilter.filter {
                ($0.elem as? OfferEntity)?.id != GlobalPositionPullOffers.pgTopPregrantedRobinsonOfferId
            }
            return updatedCarouselOfferItems
        }
    }
}
