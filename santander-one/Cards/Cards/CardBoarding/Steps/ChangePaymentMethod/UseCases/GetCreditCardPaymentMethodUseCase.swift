import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public class GetCreditCardPaymentMethodUseCase: UseCase<GetCreditCardPaymentMethodUseCaseInput, GetCreditCardPaymentMethodUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: GetCreditCardPaymentMethodUseCaseInput) throws -> UseCaseResponse<GetCreditCardPaymentMethodUseCaseOkOutput, StringErrorOutput> {
        let cardsManager = self.dependenciesResolver.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
        
        let cardDTO = requestValues.card.dto
        let responseDetailCard = try cardsManager.getCardDetail(cardDTO: cardDTO)
        guard responseDetailCard.isSuccess(), try responseDetailCard.getResponseData() != nil else {
            return .error(GetCreditCardPaymentMethodUseCaseErrorOutput(try responseDetailCard.getErrorMessage()))
        }
        
        let changePaymenteResponse = try cardsManager.getPaymentChange(cardDTO: cardDTO)
        guard changePaymenteResponse.isSuccess(), let changePaymentDTO = try changePaymenteResponse.getResponseData() else {
            return .error(GetCreditCardPaymentMethodUseCaseErrorOutput(try changePaymenteResponse.getErrorMessage()))
        }
        let changePayment = ChangePaymentEntity(changePaymentDTO)
        return .ok(GetCreditCardPaymentMethodUseCaseOkOutput(changePayment: changePayment))
    }
}

public struct GetCreditCardPaymentMethodUseCaseInput {
    let card: CardEntity
    
    public init(card: CardEntity) {
        self.card = card
    }
}

public struct GetCreditCardPaymentMethodUseCaseOkOutput {
    public let changePayment: ChangePaymentEntity
}

class GetCreditCardPaymentMethodUseCaseErrorOutput: StringErrorOutput {}
