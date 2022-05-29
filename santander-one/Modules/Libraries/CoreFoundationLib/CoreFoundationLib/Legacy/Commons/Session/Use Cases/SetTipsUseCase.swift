//
//  SetTipsUseCase.swift
//  Session
//
//  Created by José Carlos Estela Anguita on 15/9/21.
//

import Foundation

final class SetTipsUseCase: UseCase<Void, Void, StringErrorOutput> {
    private let appRepository: AppRepositoryProtocol
    private let pullOffersConfigRepository: PullOffersConfigRepositoryProtocol
    private let pullOffersInterpreter: PullOffersInterpreter
    
    init(dependenciesResolver: DependenciesResolver) {
        self.pullOffersConfigRepository = dependenciesResolver.resolve()
        self.pullOffersInterpreter = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        self.setTips()
        self.setSecurityTips()
        self.setSecurityTravelTips()
        self.setHelpCenterTips()
        self.setAtmTips()
        self.setActivateCreditCardTips()
        self.setActivateDebitCardTips()
        self.setCardBoardingWelcomeDebitCardTips()
        self.setCardBoardingWelcomeCreditCardTips()
        self.setSantanderExperiences()
        self.setCardBoardingAlmostDoneCreditTips()
        self.setCardBoardingAlmostDoneDebitTips()
        return .ok()
    }
    
    private func setTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getTips(),
            into: appRepository.setTips
        )
    }
    
    private func setSecurityTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getSecurityTips(),
            into: appRepository.setSecurityTips
        )
    }
    
    private func setSecurityTravelTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getSecurityTravelTips(),
            into: appRepository.setSecurityTravelTips
        )
    }
    
    private func setHelpCenterTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getHelpCenterTips(),
            into: appRepository.setHelpCenterTips
        )
    }
    
    private func setAtmTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getAtmTips(),
            into: appRepository.setAtmTips
        )
    }
    
    private func setActivateCreditCardTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getActivateCreditCardTips(),
            into: appRepository.setActivateCreditCardTips
        )
    }
    
    private func setActivateDebitCardTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getActivateDebitCardTips(),
            into: appRepository.setActivateDebitCardTips
        )
    }
    
    private func setCardBoardingWelcomeCreditCardTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getCardBoardingWelcomeCreditCardTips(),
            into: appRepository.setCardBoardingWelcomeCreditCardTips
        )
    }
    
    private func setCardBoardingWelcomeDebitCardTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getCardBoardingWelcomeCreditCardTips(),
            into: appRepository.setCardBoardingWelcomeCreditCardTips
        )
    }
    
    private func setSantanderExperiences() {
        self.loadTips(
            of: pullOffersConfigRepository.getSantanderExperiences(),
            into: appRepository.setSantander
        )
    }
    
    private func setCardBoardingAlmostDoneCreditTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getCardBoardingAlmostDoneCreditTips(),
            into: appRepository.setCardboardingAlmostDoneCreditTips
        )
    }
    
    private func setCardBoardingAlmostDoneDebitTips() {
        self.loadTips(
            of: pullOffersConfigRepository.getCardBoardingAlmostDoneDebitTips(),
            into: appRepository.setCardboardingAlmostDoneDebitTips(tips:)
        )
    }
}

private extension SetTipsUseCase {
    
    func loadTips(of tips: [PullOffersConfigTipDTO]?, into closure: ([PullOfferTipEntity]?) -> Void) {
        closure(tips?.compactMap(entityFromDTO))
    }
    
    func loadTips(of tips: [PullOffersConfigTipDTO]?, into closure: ([PullOfferTipEntity]?) -> RepositoryResponse<Void>) {
        _ = closure(tips?.compactMap(entityFromDTO))
    }
    
    func entityFromDTO(_ dto: PullOffersConfigTipDTO) -> PullOfferTipEntity? {
        guard
            pullOffersInterpreter.isValid(tip: dto, reload: false),
            let offerID = dto.offerId,
            let offerDTO = pullOffersInterpreter.getValidOffer(offerId: offerID)
        else {
            return nil
        }
        let tipEntity = PullOfferTipEntity(dto, offer: offerDTO)
        return tipEntity
    }
}
