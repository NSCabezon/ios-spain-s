import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidatePayLaterCardUseCase: UseCase<ValidatePayLaterCardUseCaseInput, Void, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidatePayLaterCardUseCaseInput) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let amountToDefer = requestValues.amountToDefer.amountDTO
        let payLaterDTO = requestValues.payLater.dto
        
        let response = try provider.getBsanCardsManager().confirmPayLaterData(cardDTO: cardDTO, payLaterDTO: payLaterDTO, amountDTO: amountToDefer)
        
        if response.isSuccess() {
            return UseCaseResponse.ok()
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct ValidatePayLaterCardUseCaseInput {
    let card: Card
    let amountToDefer: Amount
    let payLater: PayLater
}
