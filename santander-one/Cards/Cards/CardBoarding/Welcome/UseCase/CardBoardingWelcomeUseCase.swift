//
//  CardBoardingWelcomeUseCase.swift
//  Cards
//
//  Created by Cristobal Ramos Laina on 13/11/2020.
//

import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class CardBoardingWelcomeUseCase: UseCase<GetCardBoardingWelcomeUseCaseInput, GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
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
    
    override public func executeUseCase(requestValues: GetCardBoardingWelcomeUseCaseInput) throws -> UseCaseResponse<GetCardBoardingWelcomeUseCaseOkOutput, StringErrorOutput> {
        let tips: [PullOfferTipEntity]?
        if requestValues.card.isDebitCard {
            tips = getCardBoardingWelcomeDebitCardTips()
        } else {
            tips = getCardBoardingWelcomeCreditCardTips()
        }
        return .ok(GetCardBoardingWelcomeUseCaseOkOutput(tips: tips))
    }
}

private extension CardBoardingWelcomeUseCase {
    
    func getCardBoardingWelcomeCreditCardTips() -> [PullOfferTipEntity]? {
        guard let welcomeCreditCardTips = try? checkRepositoryResponse(appRepository.getCardBoardingWelcomeCreditCardTips()) else {
            return nil
        }
        return welcomeCreditCardTips
    }
    
    func getCardBoardingWelcomeDebitCardTips() -> [PullOfferTipEntity]? {
        guard let welcomeDebitCardTips = try? checkRepositoryResponse(appRepository.getCardBoardingWelcomeDebitCardTips()) else {
            return nil
        }
        return welcomeDebitCardTips
    }
}

struct GetCardBoardingWelcomeUseCaseInput {
    public let card: CardEntity
}

struct GetCardBoardingWelcomeUseCaseOkOutput {
    public let tips: [PullOfferTipEntity]?
}
