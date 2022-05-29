import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateUpdateNoSepaUsualTransferUseCase: UseCase<ValidateUpdateNoSepaUsualTransferUseCaseInput, ValidateUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateUpdateNoSepaUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateUpdateNoSepaUsualTransferUseCaseOkOutput, StringErrorOutput> {
        
        let noSepaPayeeDTO = NoSepaPayeeDTO(
            swiftCode: requestValues.bicSwift,
            paymentAccountDescription: requestValues.payeeAccount,
            name: requestValues.payeeName,
            town: requestValues.payeeLocation,
            address: requestValues.payeeAddress,
            countryName: requestValues.payeeCountryName,
            countryCode: requestValues.payeeCountryCode,
            bankName: requestValues.bankName,
            bankAddress: requestValues.bankAddress,
            bankTown: requestValues.bankLocation,
            bankCountryCode: requestValues.bankCountryCode,
            bankCountryName: requestValues.bankCountryName)
        
        let response = try provider.getBsanTransfersManager().validateUpdateNoSepaPayee(alias: requestValues.alias, noSepaPayeeDTO: noSepaPayeeDTO, newCurrencyDTO: requestValues.currency.currencyDTO)

        guard
            response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO)
            else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(ValidateUpdateNoSepaUsualTransferUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct ValidateUpdateNoSepaUsualTransferUseCaseInput {
    let alias: String
    let payeeName: String?
    let payeeAccount: String
    let payeeAddress: String?
    let payeeLocation: String?
    let payeeCountryName: String?
    let payeeCountryCode: String?
    let bicSwift: String?
    let bankName: String?
    let bankAddress: String?
    let bankLocation: String?
    let bankCountryCode: String?
    let bankCountryName: String?
    let currency: Currency
}

struct ValidateUpdateNoSepaUsualTransferUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
