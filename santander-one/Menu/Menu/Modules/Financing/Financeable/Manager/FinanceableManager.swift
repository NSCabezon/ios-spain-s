//
//  FinanceableManager.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 30/06/2020.
//

import CoreFoundationLib
import CoreDomain
import Foundation
import SANLegacyLibrary

enum FinanceableLocations: String, CaseIterable {
    case needMoney = "ZF_NECESITO_DINERO"
    case bigOffer = "ZF_HOME"
    case secondBigOffer = "ZF_BIG_OFFER_2"
    case carousel = "ZF_CONTRATAR_TARJETAS"
    case easyPayHighAmount = "ZF_EASY_PAY_HIGH_AMOUNT"
    case easyPayLowAmount = "ZF_EASY_PAY_LOW_AMOUNT"
    case robinson = "PRE_CONCEDIDOS_ROBINSON_BIG"
    case commercialOffer1 = "FINANCING_COMMERCIAL_OFFERS1"
    case commercialOffer2 = "FINANCING_COMMERCIAL_OFFERS2"
}

public class FinanceableInfo {
    var isSanflixEnabled: Bool = false
    var cards: [CardEntity] = []
    var amount: AmountEntity?
    var tricks: [TrickEntity]?
    var financeableCommercialOfferEntity: PullOffersFinanceableCommercialOfferEntity?
    var shouldDisplayRobinsonBanner: Bool = false
}

protocol FinanceableManagerProtocol {
    func fetch(completion: @escaping (FinanceableInfoViewModel, FinanceableInfo) -> Void)
    func fetchOffers(firstFectchInfo: FinanceableInfo, completion: @escaping (FinanceableInfoViewModel) -> Void)
}

final class FinanceableManager {
    private class State {
        private var cardsLoading: Set<CardEntity>

        init(cards: [CardEntity]) {
            self.cardsLoading = Set(cards)
        }

        func areCardsLoading() -> Bool {
            return self.cardsLoading.count > 0
        }

        func cardLoaded(_ card: CardEntity) {
            self.cardsLoading.remove(card)
        }
    }

    // MARK: - Attributes

    private let dependenciesResolver: DependenciesResolver
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().financing
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity] = [:]
    private var state = State(cards: [])
    private let financeableBuilder = InfoBuilder()
    private let info = FinanceableInfo()
    private let taskScheduler = TaskScheduler()
    private let robinsonUserCode = "2"

    // MARK: - Use Cases

    private var getLimitsUseCase: GetPregrantedLimitsUseCase {
        self.dependenciesResolver.resolve()
    }

    private var getPullOffersCandidatesUseCase: GetOffersCandidatesUseCase {
        self.dependenciesResolver.resolve()
    }

    private var useCaseHandler: UseCaseHandler {
        self.dependenciesResolver.resolve()
    }

    private var getCreditCardUseCase: GetCreditCardUseCase {
        self.dependenciesResolver.resolve(firstTypeOf: GetCreditCardUseCase.self)
    }

    private var getFinanceableConfigurationUseCase: GetFinanceableConfigurationUseCase {
        self.dependenciesResolver.resolve()
    }

    private var getFinancingTrickUseCase: GetFinancingTricksUseCase {
        return self.dependenciesResolver.resolve(for: GetFinancingTricksUseCase.self)
    }

    private var pullOffersInterpreter: PullOffersInterpreter {
        return self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
    }

    private var appConfigRepository: AppConfigRepositoryProtocol {
        return self.dependenciesResolver.resolve()
    }
    
    private var getFinanceableCommercialOffersUseCase: GetFinanceableCommercialOffersUseCase {
        self.dependenciesResolver.resolve()
    }

    var getAdobeTargetOfferUseCase: GetAdobeTargetOfferUseCaseProtocol {
        return self.dependenciesResolver.resolve(for: GetAdobeTargetOfferUseCaseProtocol.self)
    }

    // MARK: - Public methods

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension FinanceableManager: FinanceableManagerProtocol {
    func fetch(completion: @escaping (FinanceableInfoViewModel, FinanceableInfo) -> Void) {
        self.taskScheduler.schedule(self.loadConfiguration) { result in
            self.info.isSanflixEnabled = result.isSanflixEnabled
        }
        
        self.taskScheduler.schedule(self.getCreditCardList) { result in
            self.info.cards = result
            self.loadCardsFinished(self.info)
        }
        self.taskScheduler.schedule(self.loadFinancingTrick) { result in
            guard let tricks = result, !tricks.isEmpty else { return }
            self.info.tricks = tricks
        }
        self.taskScheduler.onFinished = {
            self.finish(info: self.info, completion: completion)
        }
    }
    
    func fetchOffers(firstFectchInfo: FinanceableInfo, completion: @escaping (FinanceableInfoViewModel) -> Void) {
        self.taskScheduler.schedule(self.loadFinanceableCommercialOffers) { result in
            self.info.financeableCommercialOfferEntity = result
        }
        self.taskScheduler.schedule(self.loadOffers)
        self.taskScheduler.schedule(self.checkIfRobinsonUser) { result in
            self.info.shouldDisplayRobinsonBanner = result
        }
        self.taskScheduler.onFinished = {
            self.finishOffers(firstFectchInfo: firstFectchInfo, info: self.info, completion: completion)
        }
    }
}

private extension FinanceableManager {
    func loadCardsFinished(_ configuration: FinanceableInfo) {
        return self.taskScheduler.schedule(self.loadLimits) { result in
            self.info.amount = result
        }
    }

    func loadConfiguration(completion: @escaping (GetFinanceableConfigurationUseCaseOkOutput) -> Void) {
        MainThreadUseCaseWrapper(
            with: self.getFinanceableConfigurationUseCase,
            onSuccess: { response in
                completion(response)
            }
        )
    }

    func loadOffers(completion: @escaping () -> Void) {
        MainThreadUseCaseWrapper(
            with: self.getPullOffersCandidatesUseCase.setRequestValues(requestValues: GetOffersCandidatesUseCaseInput(locations: self.locations)),
            onSuccess: { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
                completion()
            }
        )
    }
    
    func loadFinanceableCommercialOffers(completion: @escaping (PullOffersFinanceableCommercialOfferEntity?) -> Void) {
        Scenario(useCase: self.getFinanceableCommercialOffersUseCase)
            .execute(on: self.useCaseHandler)
            .onSuccess { (result) in
                completion(result.commercialOfferEntity)
            }
            .onError { _ in
                completion(nil)
            }
    }

    func loadLimits(completion: @escaping (AmountEntity?) -> Void) {
        UseCaseWrapper(
            with: self.getLimitsUseCase,
            useCaseHandler: self.useCaseHandler,
            onSuccess: { result in
                let amountEntity = AmountEntity(value: Decimal(result.loanBanner.amountLimit ?? 0))
                completion(amountEntity)
            },
            onError: { _ in
                completion(nil)
            }
        )
    }

    func getCreditCardList(completion: @escaping ([CardEntity]) -> Void) {
        MainThreadUseCaseWrapper(
            with: self.getCreditCardUseCase,
            onSuccess: { response in
                completion(response.cardList)
            }
        )
    }

    func offer(forLocation location: String) -> FinanceableInfoViewModel.Offer? {
        return self.pullOfferCandidates.location(key: location).map(FinanceableInfoViewModel.Offer.init)
    }

    func loadFinancingTrick(completion: @escaping ([TrickEntity]?) -> Void) {
        UseCaseWrapper(
            with: self.getFinancingTrickUseCase,
            useCaseHandler: self.useCaseHandler,
            onSuccess: { response in
                completion(response.financingTricks)
            },
            onError: { _ in
                completion(nil)
            }
        )
    }

    func getAdobeTarget(completion: @escaping (GetAdobeTargetOfferUseCaseOkOutput?) -> Void) {
        let input = GetAdobeTargetOfferUseCaseInput(
            groupId: "financing",
            locationId: "financing",
            channelId: "MOV",
            countryCode: "ES",
            languageCode: "ES",
            screenWidth: UIScreen.main.bounds.size.width * UIScreen.main.scale,
            screenHeight: UIScreen.main.bounds.size.height * UIScreen.main.scale,
            customerContext: "Retail",
            customerContextId: nil )
        Scenario(
            useCase: self.getAdobeTargetOfferUseCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { adobe in
                completion(adobe)
            }
            .onError { _ in
                completion(nil)
            }
    }

    func finish(info: FinanceableInfo, completion: @escaping (FinanceableInfoViewModel, FinanceableInfo) -> Void) {
        financeableBuilder.setFractionalPayment(FinanceableInfoViewModel.FractionalPaymentModel(shouldAddCreditCardBox: !info.cards.isEmpty))
        self.financeableBuilder.setCardsCarousel(FinanceableInfoViewModel.CardsCarousel(
            cards: info.cards,
            isSanflixEnabled: info.isSanflixEnabled,
            offer: self.offer(forLocation: FinanceableLocations.carousel.rawValue)
        )
        )
        if let tricks = info.tricks {
            self.financeableBuilder.setTricks(FinanceableInfoViewModel.Tricks(tricks: tricks))
        }
            completion(self.financeableBuilder.build(), info)
    }
    
    func finishOffers(firstFectchInfo: FinanceableInfo, info: FinanceableInfo, completion: @escaping (FinanceableInfoViewModel) -> Void) {
        // Need money
        if let amount = firstFectchInfo.amount,
           let offer = offer(forLocation: FinanceableLocations.needMoney.rawValue) {
            let viewModel = FinanceableInfoViewModel.NeedMoney(amount: amount,
                                                               offer: offer)
            self.financeableBuilder.setPreconceivedBanner(viewModel)
        }
        // Commercial Offers
        if let commercialOffersEntity = info.financeableCommercialOfferEntity,
           let offerEntities = commercialOffersEntity.offers,
           !offerEntities.isEmpty {
            let commercialOffers = getCommercialOffers(offerEntities)
            let entity = FinanceableInfoViewModel.CommercialOffers(
                entity: commercialOffersEntity,
                offers: commercialOffers
            )
            self.financeableBuilder.setCommercialOffers(entity)
        }
        if info.shouldDisplayRobinsonBanner,
           firstFectchInfo.amount != nil,
           let offer = self.pullOffersInterpreter.getOffer(offerId: FinanceableLocations.robinson.rawValue),
           let pullOfferLocation = self.locations.filter({ $0.stringTag == FinanceableLocations.robinson.rawValue }).first {
            let offerEntity = OfferEntity(offer)
            self.financeableBuilder.setRobinsonOffer(
                FinanceableInfoViewModel.BigOffer(
                    offer: FinanceableInfoViewModel.Offer(location: pullOfferLocation,
                                                          offer: offerEntity)
                )
            )
        }
        if self.appConfigRepository.getBool(FinancingConstants.adobeTargetOfferEnabled) ?? false {
            getAdobeTarget(completion: { adobeTargetOfferRepresentable in
                if let adobe =  adobeTargetOfferRepresentable?.adobeTargetOffer {
                    let target = FinanceableInfoViewModel.AdobeTarget(data: adobe)
                    self.financeableBuilder.setAdobeTarget(target)
                    completion(self.financeableBuilder.build())
                } else {
                    completion(self.financeableBuilder.build())
                }
            })
        } else {
            completion(self.financeableBuilder.build())
        }

    }

    func checkIfRobinsonUser(completion: @escaping (Bool) -> Void) {
        let getUserCampaignsUseCase: GetUserCampaignsUseCase = self.dependenciesResolver.resolve(for: GetUserCampaignsUseCase.self)
        Scenario(useCase: getUserCampaignsUseCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { output in
                let robinsonUserCode = "2"
                let campaigns = output.campaigns
                let isInRobinsonList = campaigns.filter { $0 == robinsonUserCode }.first != nil
                completion(isInRobinsonList)
            }
            .onError { _ in
                completion(false)
            }
    }
    
    func getCommercialOffers(_ offerEntities: [PullOffersFinanceableCommercialOfferPillEntity]) -> [FinanceableInfoViewModel.Offer] {
        var offers = [FinanceableInfoViewModel.Offer]()
        offerEntities.forEach { (item) in
            guard
                let locationId = item.locationId,
                self.locations.filter({ $0.stringTag == locationId }).first != nil,
                let offer = self.offer(forLocation: locationId)
            else {
                return
            }
            offers.append(offer)
        }
        return offers
    }
}
