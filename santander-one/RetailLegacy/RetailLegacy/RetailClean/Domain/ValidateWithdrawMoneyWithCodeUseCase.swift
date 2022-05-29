import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateWithdrawMoneyWithCodeUseCase: UseCase<ValidateWithdrawMoneyWithCodeUseCaseInput, ValidateWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateWithdrawMoneyWithCodeUseCaseInput) throws -> UseCaseResponse<ValidateWithdrawMoneyWithCodeUseCaseOkOutput, StringErrorOutput> {
        let manager = provider.getBsanCashWithdrawalManager()
        let cardDTO =  requestValues.card.cardDTO
        let responseDetailToken = try manager.getCardDetailToken(cardDTO: cardDTO, cardTokenType: CardTokenType.panWithoutSpaces)
        guard responseDetailToken.isSuccess(), let token = try responseDetailToken.getResponseData() else {
            let errorDescription = try responseDetailToken.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        let response = try manager.validatePIN(cardDTO: cardDTO, cardDetailTokenDTO: token)
        guard response.isSuccess(), let signatureDto = try response.getResponseData() else {
            let errorDescription = try responseDetailToken.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        guard let signature = SignatureWithToken(dto: signatureDto) else {
            return  UseCaseResponse.error(StringErrorOutput(nil))
        }
        return UseCaseResponse.ok(ValidateWithdrawMoneyWithCodeUseCaseOkOutput(signature: signature))
    }
}

struct ValidateWithdrawMoneyWithCodeUseCaseInput {
    let card: Card
}

struct ValidateWithdrawMoneyWithCodeUseCaseOkOutput {
    let signature: SignatureWithToken
}
