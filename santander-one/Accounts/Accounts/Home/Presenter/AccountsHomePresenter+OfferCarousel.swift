//
//  AccountsHomePresenter+OfferCarousel.swift
//  Account
//
//  Created by Rubén Márquez Fernández on 30/7/21.
//

import CoreFoundationLib
import OfferCarousel

extension AccountsHomePresenter {
    func loadOfferCarousel() {
        Scenario(
            useCase: GetAccountCarouselOffersUseCase(dependenciesResolver: self.dependenciesResolver),
            input: GetAccountCarouselOffersUseCaseInput(locations: PullOffersLocationsFactoryEntity().accountsHomeLocations))
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { output in
                self.buildCarouselOffer(output: output)
            }
            .onError { _ in
                self.view?.setAccountOfferCarousel(offers: [])
            }
    }
    
    private func buildCarouselOffer(output: GetAccountCarouselOffersUseCaseOkOutput) {
        let configuration = PregrantedConfiguration(
            isVisible: output.isAccountOfferCarouselEnabled,
            isPGTopPregrantedBannerEnable: output.isPGTopPregrantedBannerEnable,
            pregrantedBannerColor: PregrantedBannerColor(value: (output.pregrantedBannerColor).lowercased()),
            pregrantedBannerText: output.pregrantedBannerText,
            pgTopPregrantedBannerStartedText: output.pregrantedBannerStartedText
        )
        // Create carouselOfferViewModels
        let carouselOfferViewModels = (output.accountTopOffers ?? []).map({ (offer) in
            return CarouselOfferViewModel(
                imgURL: offer.banner?.url,
                height: offer.banner?.height,
                elem: offer,
                transparentClosure: offer.transparentClosure
            )
        })
        let pullOfferCandidates = output.pullOfferCandidates
        self.carouselOfferBuilder?.build(
            pregrantedConfiguration: configuration,
            shouldDisplayRobinsonBanner: output.isPGTopPregrantedBannerEnable && output.isRobinsonUser,
            carouselOfferViewModels: carouselOfferViewModels,
            pullOfferCandidates: pullOfferCandidates
        )
        self.setPregrantedLimits(output: output)
    }
    
    private func setPregrantedLimits(output: GetAccountCarouselOffersUseCaseOkOutput) {
        let pullOfferCandidates = output.pullOfferCandidates
        Scenario(useCase: GetPregrantedLimitsUseCase(resolver: self.dependenciesResolver))
            .execute(on: self.dependenciesResolver.resolve(for: UseCaseHandler.self))
            .onSuccess { [weak self] result in
                guard let self = self else { return }
                self.carouselOfferBuilder?.setPregrantedBanner(display: true)
                guard let simulatorLocation = pullOfferCandidates
                        .filter({ $0.key.stringTag == GlobalPositionPullOffers.loansSimulator }).first
                else { return }
                let pregrantedViewModel = PregrantedViewModel(
                    entity: result.loanBanner,
                    offerLocation: simulatorLocation.key,
                    offerEntity: simulatorLocation.value
                )
                self.carouselOfferBuilder?.setPregrantedViewModel(pregrantedViewModel: pregrantedViewModel)
                self.carouselOfferBuilder?.setPregrantedOfferEntity(pregrantedOfferEntity: simulatorLocation.value)
            }
            .finally {
                self.view?.setAccountOfferCarousel(offers: self.getOfferCarousel())
            }
    }
    
    private func getOfferCarousel() -> [OfferCarouselViewModel] {
        let offerCarouselViewModel: OfferCarouselViewModel? = self.carouselOfferBuilder?.createOfferCarouselCells()
        if let offerCarouselViewModel = offerCarouselViewModel {
            return [offerCarouselViewModel]
        } else {
            return []
        }
    }
}
