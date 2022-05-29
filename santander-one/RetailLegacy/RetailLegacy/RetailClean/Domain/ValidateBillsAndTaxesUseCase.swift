import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateBillsAndTaxesUseCase: UseCase<ValidateBillsAndTaxesUseCaseInput, ValidateBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateBillsAndTaxesUseCaseInput) throws -> UseCaseResponse<ValidateBillsAndTaxesUseCaseOkOutput, StringErrorOutput> {
        let accountDTO = requestValues.account.accountDTO
        let directDebit = requestValues.directDebit
        let amountDTO = requestValues.amount.amountDTO
        
        let response = try provider.getBsanBillTaxesManager().consultSignatureBillAndTaxes(chargeAccountDTO: accountDTO, directDebit: directDebit, amountDTO: amountDTO)
        
        if response.isSuccess(), let signatureWithTokenDTO = try response.getResponseData(), let signature = SignatureWithToken(dto: signatureWithTokenDTO) {
            return UseCaseResponse.ok(ValidateBillsAndTaxesUseCaseOkOutput(signatureWithToken: signature))
        }
        let errorDescription = try response.getErrorMessage() ?? ""
        return UseCaseResponse.error(StringErrorOutput(errorDescription))
    }
}

struct ValidateBillsAndTaxesUseCaseInput {
    let account: Account
    let directDebit: Bool
    let amount: Amount
}

struct ValidateBillsAndTaxesUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
