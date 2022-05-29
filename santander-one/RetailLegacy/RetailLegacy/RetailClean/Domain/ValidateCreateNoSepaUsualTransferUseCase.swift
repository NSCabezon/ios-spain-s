import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateCreateNoSepaUsualTransferUseCase: UseCase<ValidateCreateNoSepaUsualTransferUseCaseInput, ValidateCreateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateCreateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateCreateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let alias = requestValues.alias
        let noSepaPayeeDTO = requestValues.noSepaPayee?.noSepaPayeeDTO
        let currencyDTO = requestValues.currency.currencyDTO
        
        let response = try provider.getBsanTransfersManager().validateCreateNoSepaPayee(newAlias: alias, newCurrency: currencyDTO, noSepaPayeeDTO: noSepaPayeeDTO)
        
        guard
            response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO) else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        
        return UseCaseResponse.ok(ValidateCreateNoSepaUsualTransferUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct ValidateCreateNoSepaUsualTransferUseCaseInput {
    let alias: String
    let currency: Currency
    let noSepaPayee: NoSepaPayee?
}

struct ValidateCreateNoSepaUsualTransferUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
