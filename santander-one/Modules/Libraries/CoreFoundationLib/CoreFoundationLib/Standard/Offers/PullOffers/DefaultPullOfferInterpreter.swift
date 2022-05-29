import Foundation
import CoreDomain
import OpenCombine

public class DefaultPullOfferInterpreter {
    private let dependenciesResolver: OffersDependenciesResolver
    
    init(dependenciesResolver: OffersDependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension DefaultPullOfferInterpreter {
    var pullOfferInterpreter: PullOffersInterpreter {
        return dependenciesResolver.resolve()
    }
    
    var rulesRepository: ReactiveRulesRepository {
        return dependenciesResolver.resolve()
    }
    
    var pullOffersRepository: ReactivePullOffersRepository {
        return dependenciesResolver.resolve()
    }
    
    var pullOffersEngine: EngineInterface {
        return dependenciesResolver.resolve()
    }
    
    var offersRepository: ReactiveOffersRepository {
        return dependenciesResolver.resolve()
    }
}

extension DefaultPullOfferInterpreter: ReactivePullOffersInterpreter {
    public func getValidOffer(offerId: String) -> AnyPublisher<OfferRepresentable, Error> {
        Publishers.Zip(
            getOfferPublisher(offerId: offerId),
            rulesRepository.fetchRulesPublisher().setFailureType(to: Error.self)
        )
            .flatMap(checkIsValidOffer)
            .eraseToAnyPublisher()
    }
}

private extension DefaultPullOfferInterpreter {
    func getOfferPublisher(offerId: String) -> AnyPublisher<OfferRepresentable, Error> {
        return Publishers.Zip(
            pullOffersRepository.fetchSessionDisabledOffers(),
            offersRepository.fetchOffersPublisher())
            .subscribe(on: DispatchQueue.global().ocombine)
            .flatMap({ [unowned self] (disabled, offers) in
                self.checkOfferIsNotDisabled(offerId, disabledOffers: disabled, offers: offers)
            })
            .eraseToAnyPublisher()
    }
    
    func checkIsValidOffer(_ offer: OfferRepresentable, _ rules: [RuleRepresentable]) -> AnyPublisher<OfferRepresentable, Error> {
        guard verifyDates(offer: offer)
        else { return Fail(error: NSError(description: "no-valid-offer")).eraseToAnyPublisher() }
        return fetchEvaluatedRules(offer, rules: rules, reload: false)
            .flatMap({ [unowned self] resp in
                return self.evaluateRulesResponse(resp, offer: offer)
            })
            .eraseToAnyPublisher()
    }
    
    func fetchEvaluatedRules(_ offer: OfferRepresentable, rules: [RuleRepresentable], reload: Bool) -> AnyPublisher<[Bool], Error> {
        let rulesReactive = offer.rulesIds.map { ruleId in
            evaluatedRule(ruleId: ruleId, reload: reload, rules: rules)
                .setFailureType(to: Error.self)
        }
        return Publishers
            .MergeMany(rulesReactive)
            .collect()
            .eraseToAnyPublisher()
    }
    
    func evaluatedRule(ruleId: String, reload: Bool, rules: [RuleRepresentable]) -> AnyPublisher<Bool, Never> {
        guard !reload
        else { return Just(evaluateRule(ruleId: ruleId, rules: rules)).eraseToAnyPublisher() }
        return pullOffersRepository.isValidRule(identifier: ruleId)
            .map({ [unowned self] isValid in
                guard let valid = isValid else { return evaluateAndUpdateRule(ruleId: ruleId, rules: rules) }
                return valid
            })
            .eraseToAnyPublisher()
    }
    
    func evaluateAndUpdateRule(ruleId: String, rules: [RuleRepresentable]) -> Bool {
        let isValid = evaluateRule(ruleId: ruleId, rules: rules)
        pullOffersRepository.setRule(identifier: ruleId, isValid: isValid)
        return isValid
    }
    
    func evaluateRule(ruleId: String, rules: [RuleRepresentable]) -> Bool {
        guard rules.isNotEmpty,
              let rule = rules.first(where: { rule in return rule.identifier == ruleId })
        else { return false }
        return pullOffersEngine.isValid(expression: rule.expression)
    }
    
    func evaluateRulesResponse(_ validRules: [Bool], offer: OfferRepresentable) -> Future<OfferRepresentable, Error> {
        return Future { promise in
            guard !validRules.contains(false)
            else { return promise(.failure(RepositoryError.error(NSError(description: "rule-already-used")))) }
            promise(.success(offer))
        }
    }
    
    func verifyDates(offer: OfferRepresentable) -> Bool {
        let today = Date()
        if let date = offer.startDateUTC, today < date {
            return false
        }
        if let date = offer.endDateUTC, today > date {
            return false
        }
        return true
    }
    
    func checkOfferIsNotDisabled(_ offerId: String, disabledOffers: [String], offers: [OfferRepresentable]) -> Future<OfferRepresentable, Error>  {
        return Future { promise in
            guard !disabledOffers.contains(offerId),
                  let offer = offers.first(where: { offer in offer.identifier == offerId })
            else { return promise(.failure(RepositoryError.error(NSError(description: "no-offer")))) }
            promise(.success(offer))
        }
    }
}
