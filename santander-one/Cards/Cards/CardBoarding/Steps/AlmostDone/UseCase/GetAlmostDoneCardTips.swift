//
//  GetAlmostDoneCardTipsUseCase.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 19/10/2020.
//

import CoreFoundationLib

final class GetAlmostDoneCardTipsUseCase: UseCase<GetAlmostDoneCardTipsUseCaseInput, GetAlmostDoneCardTipsUseCaseOkOutPut, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let pullOfferInterPreter: PullOffersInterpreter
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.pullOfferInterPreter = dependenciesResolver.resolve(for: PullOffersInterpreter.self)
    }
    
    override func executeUseCase(requestValues: GetAlmostDoneCardTipsUseCaseInput) throws -> UseCaseResponse<GetAlmostDoneCardTipsUseCaseOkOutPut, StringErrorOutput> {
        let appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        let cardType = requestValues.card.cardType
        let repositoryRequest = cardType == .credit ? appRepository.getCardboardingAlmostDoneCreditTips() : appRepository.getCardboardingAlmostDoneDebitTips()
        
        guard repositoryRequest.isSuccess(), let almostDoneTips = try repositoryRequest.getResponseData() else {
            let errorDescription = try repositoryRequest.getErrorMessage()
            return .error(StringErrorOutput(errorDescription))
        }
        return .ok(GetAlmostDoneCardTipsUseCaseOkOutPut(cardTips: almostDoneTips))
    }
}

struct GetAlmostDoneCardTipsUseCaseOkOutPut {
    let cardTips: [PullOfferTipEntity]?
}

struct GetAlmostDoneCardTipsUseCaseInput {
    let card: CardEntity
}
