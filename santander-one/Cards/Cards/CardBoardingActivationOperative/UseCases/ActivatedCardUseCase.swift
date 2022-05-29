//
//  ActivatedCardUseCase.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/10/2020.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

final class ActivatedCardUseCase: UseCase<GetActivatedCardUseCaseInput, GetActivatedCardUseCaseOkOutput, StringErrorOutput> {
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
    
    override func executeUseCase(requestValues: GetActivatedCardUseCaseInput) throws -> UseCaseResponse<GetActivatedCardUseCaseOkOutput, StringErrorOutput> {
        let tips: [PullOfferTipEntity]?
        if requestValues.card.isDebitCard {
            tips = getActivateDebitCardTips()
        } else {
            tips = getActivateCreditCardTips()
        }
        return .ok(GetActivatedCardUseCaseOkOutput(tips: tips))
    }
}

private extension ActivatedCardUseCase {
    
    func getActivateCreditCardTips() -> [PullOfferTipEntity]? {
        guard let activateCreditCardTips = try? checkRepositoryResponse(appRepository.getActivateCreditCardTips()) else {
            return nil
        }
        return activateCreditCardTips
    }
    
    func getActivateDebitCardTips() -> [PullOfferTipEntity]? {
        guard let activateDebitCardTips = try? checkRepositoryResponse(appRepository.getActivateDebitCardTips()) else {
            return nil
        }
        return activateDebitCardTips
    }
}

struct GetActivatedCardUseCaseInput {
    let card: CardEntity
    
    init(card: CardEntity) {
        self.card = card
    }
}

struct GetActivatedCardUseCaseOkOutput {
    let tips: [PullOfferTipEntity]?
    
    init(tips: [PullOfferTipEntity]?) {
        self.tips = tips
    }
}
