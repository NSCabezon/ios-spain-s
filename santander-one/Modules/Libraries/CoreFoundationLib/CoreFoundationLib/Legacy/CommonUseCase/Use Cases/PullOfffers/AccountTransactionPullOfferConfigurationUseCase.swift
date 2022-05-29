//
//  AccountTransactionPullOfferConfigurationUseCase.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 16/09/2020.
//

import SANLegacyLibrary

public final class AccountTransactionPullOfferConfigurationUseCase: UseCase<AccountTransactionOfferConfigurationUseCaseInput, AccountTransactionOfferConfigurationUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let pullOffersInterpreter: PullOffersInterpreter
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
    }
    
    public override func executeUseCase(requestValues: AccountTransactionOfferConfigurationUseCaseInput) throws -> UseCaseResponse<AccountTransactionOfferConfigurationUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let userId: String = globalPosition.userId else {
            return .ok(AccountTransactionOfferConfigurationUseCaseOkOutput(pullOfferCandidates: [:]))
        }
        self.addNewRules(requestValues: requestValues)
        self.addSpecifics(requestValues.specificLocations,
                          userId: userId,
                          filterToApply: requestValues.filterToApply)
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        var allLocations = requestValues.locations
        allLocations.append(contentsOf: requestValues.specificLocations)
        for location in allLocations {
            if let candidate = self.pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                outputCandidates[location] = OfferEntity(candidate, location: location)
            }
        }
        return .ok(AccountTransactionOfferConfigurationUseCaseOkOutput(pullOfferCandidates: outputCandidates))
    }
}

private extension AccountTransactionPullOfferConfigurationUseCase {
    func addNewRules(requestValues: AccountTransactionOfferConfigurationUseCaseInput) {
        let pullOffersEngine = self.dependenciesResolver.resolve(for: EngineInterface.self)
        var output = [String: Any]()
        output["CMDA"] = requestValues.account.alias?.uppercased() ?? ""
        output["CMDS"] = requestValues.account.getAmount()?.value?.doubleValue ?? 0
        output["CMDD"] = requestValues.transaction.alias?.uppercased() ?? ""
        output["CMDI"] = requestValues.transaction.amount?.value?.doubleValue ?? 0
        pullOffersEngine.addRules(rules: output)
    }
    
    func addSpecifics(_ locationInputs: [PullOfferLocation], userId: String, filterToApply: FilterAccountLocation?) {
        let pullOffersConfigRepository = dependenciesResolver.resolve(for: PullOffersConfigRepositoryProtocol.self)
        var newLocations: [String: [String]] = [:]
        let locationIds = locationInputs.map { $0.stringTag }
        let locations = pullOffersConfigRepository.getLocations() ?? [:]
        for location in locations.keys where locationIds.contains(location) {
            newLocations[location] = locations[location]
            self.pullOffersInterpreter.removeOffer(location: location)
        }
        if let filterToApply = filterToApply {
            if newLocations[filterToApply.location]?.indices.contains(filterToApply.indexOffer) ?? false,
               let offer = newLocations[filterToApply.location]?[filterToApply.indexOffer] {
                newLocations[filterToApply.location] = [offer]
            } else {
                newLocations[filterToApply.location] = []
            }
        }
        self.pullOffersInterpreter.setCandidates(locations: newLocations, userId: userId, reload: true)
    }
}

public struct FilterAccountLocation {
    public let location: String
    public let indexOffer: Int
    
    public init(location: String, indexOffer: Int) {
        self.location = location
        self.indexOffer = indexOffer
    }
}

public struct AccountTransactionOfferConfigurationUseCaseInput {
    public let account: AccountEntity
    public let transaction: AccountTransactionEntity
    public let locations: [PullOfferLocation]
    public let specificLocations: [PullOfferLocation]
    public let filterToApply: FilterAccountLocation?
    
    public init(account: AccountEntity, transaction: AccountTransactionEntity, locations: [PullOfferLocation], specificLocations: [PullOfferLocation], filterToApply: FilterAccountLocation?) {
        self.account = account
        self.transaction = transaction
        self.locations = locations
        self.specificLocations = specificLocations
        self.filterToApply = filterToApply
    }
    
}

public struct AccountTransactionOfferConfigurationUseCaseOkOutput {
    public let pullOfferCandidates: [PullOfferLocation: OfferEntity]
    
    public init(pullOfferCandidates: [PullOfferLocation: OfferEntity]) {
        self.pullOfferCandidates = pullOfferCandidates
    }
}
