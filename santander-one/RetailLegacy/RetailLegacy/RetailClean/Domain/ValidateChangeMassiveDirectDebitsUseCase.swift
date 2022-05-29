import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateChangeMassiveDirectDebitsUseCase: UseCase<ValidateChangeMassiveDirectDebitsUseCaseInput, ValidateChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
    
    let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: ValidateChangeMassiveDirectDebitsUseCaseInput) throws -> UseCaseResponse<ValidateChangeMassiveDirectDebitsUseCaseOkOutput, StringErrorOutput> {
        let response = try bsanManagersProvider.getBsanBillTaxesManager().validateChangeMassiveDirectDebitsAccount(originAccount: requestValues.originAccount.accountDTO, destinationAccount: requestValues.destinationAccount.accountDTO)
        guard response.isSuccess(), let responseData = try response.getResponseData(), let signature = SignatureWithToken(dto: responseData) else {
            let errorMessage = try response.getErrorMessage() ?? ""
            return .error(StringErrorOutput(errorMessage))
        }
        return .ok(ValidateChangeMassiveDirectDebitsUseCaseOkOutput(signatureWithToken: signature))
    }
}

struct ValidateChangeMassiveDirectDebitsUseCaseInput {
    let originAccount: Account
    let destinationAccount: Account
}

struct ValidateChangeMassiveDirectDebitsUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
