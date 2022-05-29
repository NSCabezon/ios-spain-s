//
//  CardTransactionPullOfferConfigurationUseCase.swift
//  Cards
//
//  Created by Margaret López Calderón on 5/8/21.
//

public final class CardTransactionPullOfferConfigurationUseCase: UseCase<CardTransactionPullOffersConfigurationUseCaseInput, CardTransactionPullOffersConfigurationUseCaseOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let pullOffersInterpreter: PullOffersInterpreter
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
    }
    
    public override func executeUseCase(requestValues: CardTransactionPullOffersConfigurationUseCaseInput) throws -> UseCaseResponse<CardTransactionPullOffersConfigurationUseCaseOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        self.addNewRules(requestValues: requestValues)
        self.addSpecifics(requestValues.specificLocations, filterToApply: requestValues.filterToApply)
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in requestValues.specificLocations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        return .ok(CardTransactionPullOffersConfigurationUseCaseOutput(pullOfferCandidates: outputCandidates))
    }
}

private extension CardTransactionPullOfferConfigurationUseCase {
    func addNewRules(requestValues: CardTransactionPullOffersConfigurationUseCaseInput) {
        let pullOffersEngine = self.dependenciesResolver.resolve(for: EngineInterface.self)
        var output = [String: Any]()
        // Rules by cards
        output["TMDA"] = "\"\(requestValues.card.alias ?? "")\""
        switch requestValues.card.cardType {
        case .credit:
            output["TMDT"] = "\"credito\""
        case .debit:
            output["TMDT"] = "\"debito\""
        case .prepaid:
            output["TMDT"] = "\"prepago\""
        }
        output["TMDD"] = "\"\(requestValues.transaction.description ?? "")\""
        output["TMDI"] = "\"\(requestValues.transaction.amount?.value?.doubleValue ?? 0)\""
        pullOffersEngine.addRules(rules: output)
    }
    
    func addSpecifics(_ locationInputs: [PullOfferLocation], filterToApply: FilterCardLocation) {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId: String = globalPosition.userId else { return }
        var newLocations: [String: [String]] = [:]
        let locationIds = locationInputs.map { $0.stringTag }
        let locations = pullOffersConfigRepository.getLocations() ?? [:]
        for location in locations.keys where locationIds.contains(location) {
            newLocations[location] = locations[location]
            pullOffersInterpreter.removeOffer(location: location)
        }
        
        if newLocations[filterToApply.location]?.indices.contains(filterToApply.indexOffer) ?? false,
           let offer = newLocations[CardsPullOffers.homeCrossSelling]?[filterToApply.indexOffer] {
            newLocations[filterToApply.location] = [offer]
        } else {
            newLocations[filterToApply.location] = []
        }
        pullOffersInterpreter.setCandidates(locations: newLocations, userId: userId, reload: true)
    }
    
}

public struct FilterCardLocation {
    public let location: String
    public let indexOffer: Int
    
    public init(location: String, indexOffer: Int) {
        self.location = location
        self.indexOffer = indexOffer
    }
    
}

public struct CardTransactionPullOffersConfigurationUseCaseInput {
    public let transaction: CardTransactionEntityProtocol
    public let card: CardEntity
    public let specificLocations: [PullOfferLocation]
    public let filterToApply: FilterCardLocation
    
    public init(transaction: CardTransactionEntityProtocol, card: CardEntity, specificLocations: [PullOfferLocation], filterToApply: FilterCardLocation) {
        self.transaction = transaction
        self.card = card
        self.specificLocations = specificLocations
        self.filterToApply = filterToApply
    }
}

public struct CardTransactionPullOffersConfigurationUseCaseOutput {
    public let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    
    public init(pullOfferCandidates: [PullOfferLocation: OfferEntity]) {
        self.pullOfferCandidates = pullOfferCandidates
    }
}
