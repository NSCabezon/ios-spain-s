import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class ConfirmDirectMoneyUseCase: ConfirmUseCase<ConfirmDirectMoneyUseCaseInput, Void, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmDirectMoneyUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorSignatureErrorOutput> {
        let cardDTO = requestValues.card.cardDTO
        let signatureDTO = requestValues.signature.dto
        let amountDto = requestValues.amount.amountDTO
        let response = try provider.getBsanCardsManager().confirmDirectMoney(cardDTO: cardDTO, amountValidatedDTO: amountDto, signatureDTO: signatureDTO)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        } else {
            let signatureType = try getSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct ConfirmDirectMoneyUseCaseInput {
    let card: Card
    let amount: Amount
    let signature: Signature
}
