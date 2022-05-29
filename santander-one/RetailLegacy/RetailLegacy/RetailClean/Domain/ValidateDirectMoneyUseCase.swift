import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class ValidateDirectMoneyUseCase: UseCase<ValidateDirectMoneyUseCaseInput, ValidateDirectMoneyUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateDirectMoneyUseCaseInput) throws -> UseCaseResponse<ValidateDirectMoneyUseCaseOkOutput, StringErrorOutput> {
        let cardDto = requestValues.card.cardDTO
        let amountDto = requestValues.amount.amountDTO
        let response = try provider.getBsanCardsManager().validateDirectMoney(cardDTO: cardDto, amountValidatedDTO: amountDto)
        if response.isSuccess(), let data = try response.getResponseData(), let signatureDto = data.signature {
            let directMoneyValidate = DirectMoneyValidate(dto: data)
            let signature = Signature(dto: signatureDto)
            return UseCaseResponse.ok(ValidateDirectMoneyUseCaseOkOutput(directMoneyValidate: directMoneyValidate, signature: signature))
        } else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
    }
}

struct ValidateDirectMoneyUseCaseInput {
    let card: Card
    let amount: Amount
}

struct ValidateDirectMoneyUseCaseOkOutput {
    let directMoneyValidate: DirectMoneyValidate
    let signature: Signature
}
