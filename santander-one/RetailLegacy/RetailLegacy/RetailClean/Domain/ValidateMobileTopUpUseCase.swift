import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateMobileTopUpUseCase: UseCase<ValidateMobileTopUpUseCaseInput, ValidateMobileTopUpUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateMobileTopUpUseCaseInput) throws -> UseCaseResponse<ValidateMobileTopUpUseCaseOkOutput, StringErrorOutput> {
        let cardDto = requestValues.card.cardDTO
        let response = try provider.getBsanMobileRechargeManager().validateMobileRecharge(card: cardDto)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let error = try response.getErrorMessage()
            return UseCaseResponse.error(StringErrorOutput(error))
        }
        let validate = ValidateMobileRecharge(validateMobileRechargeDto: data)
        return UseCaseResponse.ok(ValidateMobileTopUpUseCaseOkOutput(validateMobileRecharge: validate))
    }
}

struct ValidateMobileTopUpUseCaseInput {
    let card: Card
}

struct ValidateMobileTopUpUseCaseOkOutput {
    let validateMobileRecharge: ValidateMobileRecharge
}
