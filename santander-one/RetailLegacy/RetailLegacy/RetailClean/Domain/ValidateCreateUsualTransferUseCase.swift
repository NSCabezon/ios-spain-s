import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateCreateUsualTransferUseCase: UseCase<ValidateCreateUsualTransferUseCaseInput, ValidateCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateCreateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateCreateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let ibanDTO = requestValues.iban.ibanDTO
        let alias = requestValues.alias
        let beneficiaryName = requestValues.beneficiaryName
        let recipientType: FavoriteRecipientType
        if ibanDTO.countryCode.uppercased() == "ES" {
            recipientType = .national
        } else {
            recipientType = .international
        }
        let response = try provider.getBsanTransfersManager().validateCreateSepaPayee(alias: alias, recipientType: recipientType, beneficiary: beneficiaryName, iban: ibanDTO, serviceType: nil, contractType: nil, accountIdType: nil, accountId: nil, streetName: nil, townName: nil, location: nil, country: nil, operationDate: Date())
        guard
            response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signature = signatureWithTokenDTO,
            let signatureWithToken = SignatureWithToken(dto: signature) else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        
        return UseCaseResponse.ok(ValidateCreateUsualTransferUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct ValidateCreateUsualTransferUseCaseInput {
    let alias: String
    let beneficiaryName: String
    let iban: IBAN
}

struct ValidateCreateUsualTransferUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
