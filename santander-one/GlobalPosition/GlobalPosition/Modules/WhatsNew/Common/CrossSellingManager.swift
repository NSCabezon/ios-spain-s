import CoreFoundationLib

final class CrossSellingManager {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func loadCardCandidatesOffersForViewModel(_ item: UnreadMovementItem,
                                              transaction: CardTransactionWithCardEntity,
                                              indexTag: Int,
                                              completion: @escaping (OfferEntity?) -> Void) {
        Scenario(useCase: cardTransactionPullOffersUseCase,
                 input: CardTransactionPullOffersConfigurationUseCaseInput(
                    transaction: transaction.cardTransactionEntity,
                    card: transaction.cardEntity,
                    specificLocations: PullOffersLocationsFactoryEntity().cards,
                    filterToApply: FilterCardLocation(location: CardsPullOffers.homeCrossSelling,
                                                      indexOffer: indexTag)
                 ))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { result in
                guard let candidates = result.pullOfferCandidates.location(key: CardsPullOffers.homeCrossSelling) else {
                    completion(nil)
                    return
                }
                completion(candidates.offer)
            }
    }
    
    func loadAccountCandidatesOffersForViewModel(_ item: UnreadMovementItem,
                                                 transaction: AccountTransactionWithAccountEntity,
                                                 indexTag: Int,
                                                 completion: @escaping (OfferEntity?) -> Void) {
        Scenario(useCase: accountTransactionPullOffersUseCase,
                 input: AccountTransactionOfferConfigurationUseCaseInput(
                    account: transaction.accountEntity,
                    transaction: transaction.accountTransactionEntity,
                    locations: PullOffersLocationsFactoryEntity().cards,
                    specificLocations: PullOffersLocationsFactoryEntity().accountHomeCrossSelling,
                    filterToApply: FilterAccountLocation(location: AccountsPullOffers.homeCrossSelling,
                                                         indexOffer: indexTag)
                ))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { result in
                guard let candidates = result.pullOfferCandidates.location(key: AccountsPullOffers.homeCrossSelling) else {
                    completion(nil)
                    return
                }
                completion(candidates.offer)
            }
    }
}

private extension CrossSellingManager {
    var accountTransactionPullOffersUseCase: AccountTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: AccountTransactionPullOfferConfigurationUseCase.self)
    }
    
    var cardTransactionPullOffersUseCase: CardTransactionPullOfferConfigurationUseCase {
        self.dependenciesResolver.resolve(for: CardTransactionPullOfferConfigurationUseCase.self)
    }
}
