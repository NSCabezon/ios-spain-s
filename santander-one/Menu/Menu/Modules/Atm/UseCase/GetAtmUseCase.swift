//
//  GetAtmUseCase.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 02/09/2020.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

final class GetAtmUseCase: UseCase<Void, GetAtmUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    private func allowsWithdrawMoney(card: CardEntity) -> Bool {
        return card.isDebitCard && card.isContractActive && !card.isTemporallyOff
    }
    private func allowsCardLimitManagement(card: CardEntity) -> Bool {
        return card.isCreditCard || card.isDebitCard
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetAtmUseCaseOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionWithUserPrefsRepresentable = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let atmTips = getAtmTips()
        var isEnabledGetMoneyWithCode: Bool = false
        var isEnabledCardLimitManagement: Bool = false
        let isEnabledNearestAtms = appConfigRepository.getBool("enableNearestAtms") ?? false
        let cards: [CardEntity] = globalPosition.cards.visibles()
        let existsCardLimitManagement = cards.first { allowsCardLimitManagement(card: $0) }
        if existsCardLimitManagement != nil && appConfigRepository.getBool("enableCardSuperSpeed") ?? false {
            isEnabledCardLimitManagement = true
        }
        let existsOneCardWithdrawMoney = cards.first { allowsWithdrawMoney(card: $0) }
        if existsOneCardWithdrawMoney != nil && appConfigRepository.getBool("enableCashWithdrawal") ?? false {
            isEnabledGetMoneyWithCode = true
        }

        return .ok(GetAtmUseCaseOkOutput(atmTips: atmTips, isEnabledGetMoneyWithCode: isEnabledGetMoneyWithCode, isEnabledCardLimitManagement: isEnabledCardLimitManagement, isEnabledNearestAtms: isEnabledNearestAtms))
    }
}

private extension GetAtmUseCase {
    
    func getAtmTips() -> [PullOfferTipEntity]? {
        guard let atmTips = try? checkRepositoryResponse(appRepository.getAtmTips()) ?? nil else {
            return nil
        }
        atmTips.forEach { $0.offer = containtOffer(forTip: $0) }
        return atmTips
    }
    
    // MARK: - Pull offer request
    func containtOffer(forTip tip: PullOfferTipEntity) -> OfferEntity? {
        let pullOfferInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        guard let offerId = tip.offerId, let offerDTO = pullOfferInterpreter.getOffer(offerId: offerId) else {
            return nil
        }
        return OfferEntity(offerDTO)
    }
}

struct GetAtmUseCaseOkOutput {
    let atmTips: [PullOfferTipEntity]?
    let isEnabledGetMoneyWithCode: Bool?
    let isEnabledCardLimitManagement: Bool?
    let isEnabledNearestAtms: Bool?
}
