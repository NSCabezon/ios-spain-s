//
//  GlobalSearchUseCase.swift
//  CommonUseCase
//
//  Created by alvola on 25/08/2020.
//


public class GlobalSearchUseCase: UseCase<GlobalSearchUseCaseInput, GlobalSearchUseCaseOkOutput, StringErrorOutput> {
    let searchResultsLimit = 15
    let faqsResultsLimit = 20
    
    override public func executeUseCase(requestValues: GlobalSearchUseCaseInput) throws -> UseCaseResponse<GlobalSearchUseCaseOkOutput, StringErrorOutput> {
        let baseURLProvider: BaseURLProvider = requestValues.dependenciesResolver.resolve()
        let globalPosition = requestValues.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        guard let userId = globalPosition.userCodeType else { return UseCaseResponse.error(StringErrorOutput(nil)) }
        let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol = requestValues.dependenciesResolver.resolve()
        let pullOffersInterpreter: PullOffersInterpreter = requestValues.dependenciesResolver.resolve()
        if let tipsSearchType = requestValues.tipsSearchType {
            return try self.performTipsSearch(tipsSearchType,
                                              pullOffersConfigRepository,
                                              pullOffersInterpreter)
        }
        
        let movements = requestValues.withMovements ?  getMovements(requestValues.dependenciesResolver,
                                                                    userId,
                                                                    requestValues.substring) : (cardsMovements: [],
                                                                                                accountsMovements: [])
        
        let faqs = getFAQs(requestValues.dependenciesResolver,
                           requestValues.substring)
        
        let actions = requestValues.withActions ? getActions(pullOffersConfigRepository,
                                                             pullOffersInterpreter,
                                                             requestValues.substring) : (tips: nil,
                                                                                         tipsOffers: nil)
        
        let homeTips = getHomeTips(pullOffersConfigRepository,
                                   pullOffersInterpreter,
                                   requestValues.substring)
        
        let interestTips = requestValues.withInterestTips ? getInterestTips(pullOffersConfigRepository,
                                                                            pullOffersInterpreter,
                                                                            requestValues.substring) : (tips: nil,
                                                                                                        tipsOffers: nil)
        
        return UseCaseResponse.ok(GlobalSearchUseCaseOkOutput(cardsMovements: movements.cardsMovements,
                                                              accountsMovements: movements.accountsMovements,
                                                              faqs: faqs.faqs,
                                                              globalFAQs: faqs.globalFAQs,
                                                              actionTips: actions.tips,
                                                              actionTipsOffers: actions.tipsOffers,
                                                              homeTips: homeTips.tips,
                                                              homeTipsOffers: homeTips.tipsOffers,
                                                              interestTips: interestTips.tips,
                                                              interestTipsOffers: interestTips.tipsOffers,
                                                              baseURL: baseURLProvider.baseURL))
    }
}

private extension GlobalSearchUseCase {
    
    func getMovements(_ dependenciesResolver: DependenciesResolver,
                      _ userId: String,
                      _ substring: String) -> (cardsMovements: [CardTransactionWithCardEntity], accountsMovements: [AccountTransactionWithAccountEntity]) {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let date = Date().getDateByAdding(days: -89, ignoreHours: true)
        
        var accountsMovements = globalPosition.accounts.visibles().reduce([AccountTransactionWithAccountEntity]()) { total, account in
            total + pfm.getMovementsFor(userId: userId,
                                        matches: substring,
                                        account: account,
                                        limit: searchResultsLimit,
                                        date: date).map({ movement in
                                            AccountTransactionWithAccountEntity(accountTransactionEntity: movement,
                                                                                accountEntity: account)
                                        })
        }
        sort(accountMovements: &accountsMovements)
        
        var cardsMovements = globalPosition.cards.visibles().reduce([CardTransactionWithCardEntity]()) { total, card in
            total + pfm.getMovementsFor(userId: userId,
                                        matches: substring,
                                        card: card,
                                        limit: searchResultsLimit,
                                        date: date).map({ movement in
                                            CardTransactionWithCardEntity(cardTransactionEntity: movement,
                                                                          cardEntity: card)
                                        })
        }
        sort(cardMovements: &cardsMovements)
        
        return (Array(cardsMovements.prefix(searchResultsLimit)), Array(accountsMovements.prefix(searchResultsLimit)))
    }
    
    func getFAQs(_ dependenciesResolver: DependenciesResolver,
                 _ substring: String) -> (faqs: [FaqsEntity], globalFAQs: [FaqsEntity]) {
        let faqsRepository = dependenciesResolver.resolve(for: FaqsRepositoryProtocol.self)
        let faqsListDTO = faqsRepository.getFaqsList()
        
        let faqEntityList = sortFaqsList(faqsList: [faqsListDTO?.generic ?? []],
                                         matches: substring).prefix(faqsResultsLimit)
        
        let globalFAQsEntityList = sortFaqsList(faqsList: [faqsListDTO?.globalSearch ?? []],
                                                matches: substring).prefix(faqsResultsLimit)
        
        return (Array(faqEntityList), Array(globalFAQsEntityList))
    }
    
    func getActions(_ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol,
                    _ pullOffersInterpreter: PullOffersInterpreter,
                    _ substring: String) -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        let actionTipsDTO = pullOffersConfigRepository.getActionTipsOffers()
        return pullOffersEntityFromContent(actionTipsDTO,
                                           pullOffersInterpreter,
                                           substring,
                                           false)
    }
    
    func getHomeTips(_ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol,
                     _ pullOffersInterpreter: PullOffersInterpreter,
                     _ substring: String) -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        let homeTipDtos = pullOffersConfigRepository.getHomeTips()?.compactMap({$0.content}).reduce([], +)
        let homeTipsDtosToConfigDtos = homeTipDtos.map({ $0.map { (dto) in PullOffersConfigTipDTO(dto)} })
        return pullOffersEntityFromContent(homeTipsDtosToConfigDtos,
                                           pullOffersInterpreter,
                                           substring)
    }
    
    func getInterestTips(_ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol,
                         _ pullOffersInterpreter: PullOffersInterpreter,
                         _ substring: String) -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        let interestTipsDtos = pullOffersConfigRepository.getInterestTipsOffers()
        return pullOffersEntityFromContent(interestTipsDtos,
                                           pullOffersInterpreter,
                                           substring)
    }
    
    func pullOffersEntityFromContent(_ content: [PullOffersConfigTipDTO]?,
                                     _ pullOffersInterpreter: PullOffersInterpreter,
                                     _ substring: String,
                                     _ limited: Bool = true) -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        var tipsOffers: [String: OfferEntity] = [:]
        let tips = content?.reduce([PullOfferTipEntity](), { (res, dto) in
            guard let offerId = dto.offerId,
                  let validOffer = pullOffersInterpreter.getValidOffer(offerId: offerId),
                  dto.desc?.range(of: substring, options: .caseInsensitive) != nil ||
                    dto.title?.range(of: substring, options: .caseInsensitive) != nil ||
                    (dto.keyWords ?? []).contains(where: { $0.range(of: substring, options: .caseInsensitive) != nil })
            else { return res }
            if limited && res.count >= faqsResultsLimit {
                return res
            }
            tipsOffers[offerId] = OfferEntity(validOffer)
            let entity = PullOfferTipEntity(dto,
                                            offer: validOffer)
            return res + [entity]
        })
        return (tips, tipsOffers)
    }
    
    func getAllPullOfferEntities(_ content: [PullOffersConfigTipDTO]?,
                                 _ pullOffersInterpreter: PullOffersInterpreter,
                                 _ limited: Bool = true) -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        var tipsOffers: [String: OfferEntity] = [:]
        let tips = content?.reduce([PullOfferTipEntity](), { (res, dto) in
            guard let offerId = dto.offerId,
                  let validOffer = pullOffersInterpreter.getValidOffer(offerId: offerId)
            else { return res }
            if limited && res.count >= faqsResultsLimit {
                return res
            }
            tipsOffers[offerId] = OfferEntity(validOffer)
            let entity = PullOfferTipEntity(dto,
                                            offer: validOffer)
            return res + [entity]
        })
        return (tips, tipsOffers)
    }
    
    func sortFaqsList(faqsList: [[FaqDTO]?], matches: String) -> [FaqsEntity] {
        return faqsList.reduce([FaqsEntity](), { [weak self] (total, faqs) in
                                guard total.count <= (self?.faqsResultsLimit ?? 0) else { return total }
                                return total + (faqs ?? []).compactMap({ (faq) in
                                    guard faq.question.range(of: matches, options: .caseInsensitive) != nil ||
                                            faq.answer.range(of: matches, options: .caseInsensitive) != nil ||
                                            (faq.keywords ?? []).contains(where: { $0.range(of: matches, options: .caseInsensitive) != nil })
                                    else { return nil }
                                    return FaqsEntity(faq)
                                }) })
    }
    
    func sort(cardMovements: inout [CardTransactionWithCardEntity]) {
        cardMovements.sort {
            if SortingCriteria.datesAreDifferent(dateA: $0.cardTransactionEntity.operationDate,
                                                 dateB: $1.cardTransactionEntity.operationDate) {
                return SortingCriteria.sortByDate(dateA: $0.cardTransactionEntity.operationDate,
                                                  dateB: $1.cardTransactionEntity.operationDate,
                                                  order: .orderedDescending)
            } else if SortingCriteria.panNumbersAreDifferent(panA: $0.cardEntity.pan,
                                                             panB: $1.cardEntity.pan) {
                return SortingCriteria.sortByPAN(panA: $0.cardEntity.pan,
                                                 panB: $1.cardEntity.pan)
            } else {
                return SortingCriteria.sortByAmount(firstAmount: $0.cardTransactionEntity.amount?.value,
                                                    secondAmount: $1.cardTransactionEntity.amount?.value)
            }
        }
    }
    
    func sort(accountMovements: inout [AccountTransactionWithAccountEntity]) {
        accountMovements.sort {
            if SortingCriteria.datesAreDifferent(dateA: $0.accountTransactionEntity.operationDate,
                                                 dateB: $1.accountTransactionEntity.operationDate) {
                return SortingCriteria.sortByDate(dateA: $0.accountTransactionEntity.operationDate,
                                                  dateB: $1.accountTransactionEntity.operationDate,
                                                  order: .orderedDescending)
            } else if SortingCriteria.ibanNumbersAreDifferent(firstAccount: $0.accountEntity,
                                                              secondAccount: $1.accountEntity) {
                return SortingCriteria.sortByIBAN(firstAccount: $0.accountEntity,
                                                  secondAccount: $1.accountEntity)
            } else {
                return SortingCriteria.sortByAmount(firstAmount: $0.accountTransactionEntity.amount?.value,
                                                    secondAmount: $1.accountTransactionEntity.amount?.value)
            }
        }
    }
}

// MARK: - Tips Search
private extension GlobalSearchUseCase {
    
    func performOnlyHomeTipsSearch(_ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol, _ pullOffersInterpreter: PullOffersInterpreter) throws -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        let homeTipDtos = pullOffersConfigRepository.getHomeTips()?.compactMap({$0.content}).reduce([], +)
        let homeTipsDtosToConfigDtos = homeTipDtos.map({ $0.map { (dto) in PullOffersConfigTipDTO(dto)} })
        let allHomeTips =  self.getAllPullOfferEntities(homeTipsDtosToConfigDtos, pullOffersInterpreter)
        return allHomeTips
    }
    
    func performOnlyInterestTipsSearch(_ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol,
                                       _ pullOffersInterpreter: PullOffersInterpreter) throws -> (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?) {
        let interestTipsDtos = pullOffersConfigRepository.getInterestTipsOffers()
        var tipsOffers: [String: OfferEntity] = [:]
        let tips = interestTipsDtos?.reduce([PullOfferTipEntity](), { (res, dto) in
            guard let offerId = dto.offerId,
                  let validOffer = pullOffersInterpreter.getValidOffer(offerId: offerId) else { return res }
            if res.count >= faqsResultsLimit {
                return res
            }
            tipsOffers[offerId] = OfferEntity(validOffer)
            let entity = PullOfferTipEntity(dto,
                                            offer: validOffer)
            return res + [entity]
        })
        return (tips, tipsOffers)
    }
    
    func performTipsSearch(_ tipsSearchType: TipsSearchType, _ pullOffersConfigRepository: PullOffersConfigRepositoryProtocol, _ pullOffersInterpreter: PullOffersInterpreter) throws -> UseCaseResponse<GlobalSearchUseCaseOkOutput, StringErrorOutput> {
        switch tipsSearchType {
        case .onlyInterestsTips:
            let interestsTips = try self.performOnlyInterestTipsSearch(pullOffersConfigRepository, pullOffersInterpreter)
            return .ok(self.getUseCaseResponse(interestsTips: interestsTips))
        case .onlyHomeTips:
            let homeTips = try self.performOnlyHomeTipsSearch(pullOffersConfigRepository, pullOffersInterpreter)
            return .ok(self.getUseCaseResponse(homeTips: homeTips))
        case .homeAndInterestsTips:
            let homeTips = try self.performOnlyHomeTipsSearch(pullOffersConfigRepository, pullOffersInterpreter)
            let interestsTips = try self.performOnlyInterestTipsSearch(pullOffersConfigRepository, pullOffersInterpreter)
            return .ok(self.getUseCaseResponse(interestsTips: interestsTips, homeTips: homeTips))
        }
    }
    
    func getUseCaseResponse(interestsTips: ((tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?))? = nil, homeTips: (tips: [PullOfferTipEntity]?, tipsOffers: [String: OfferEntity]?)? = nil) -> GlobalSearchUseCaseOkOutput {
        return GlobalSearchUseCaseOkOutput(cardsMovements: [],
                                           accountsMovements: [],
                                           faqs: [],
                                           globalFAQs: [],
                                           actionTips: nil,
                                           actionTipsOffers: nil,
                                           homeTips: homeTips?.tips,
                                           homeTipsOffers: homeTips?.tipsOffers,
                                           interestTips: interestsTips?.tips,
                                           interestTipsOffers: interestsTips?.tipsOffers,
                                           baseURL: nil)
    }
}

public struct GlobalSearchUseCaseOkOutput {
    public let cardsMovements: [CardTransactionWithCardEntity]
    public let accountsMovements: [AccountTransactionWithAccountEntity]
    public let faqs: [FaqsEntity]
    public let globalFAQs: [FaqsEntity]
    public let actionTips: [PullOfferTipEntity]?
    public let actionTipsOffers: [String: OfferEntity]?
    public let homeTips: [PullOfferTipEntity]?
    public let homeTipsOffers: [String: OfferEntity]?
    public let interestTips: [PullOfferTipEntity]?
    public let interestTipsOffers: [String: OfferEntity]?
    public let baseURL: String?
}

public struct GlobalSearchUseCaseInput {
    public let dependenciesResolver: DependenciesResolver
    public let substring: String
    public let withMovements: Bool
    public let withInterestTips: Bool
    public let withActions: Bool
    public let tipsSearchType: TipsSearchType?
    
    public init(dependenciesResolver: DependenciesResolver,
                substring: String,
                withMovements: Bool = true,
                withInterestTips: Bool = true,
                withActions: Bool = true,
                tipsSearchType: TipsSearchType? = nil) {
        self.dependenciesResolver = dependenciesResolver
        self.substring = substring
        self.withMovements = withMovements
        self.withInterestTips = withInterestTips
        self.withActions = withActions
        self.tipsSearchType = tipsSearchType
    }
}

public enum TipsSearchType {
    case onlyInterestsTips
    case onlyHomeTips
    case homeAndInterestsTips
}
