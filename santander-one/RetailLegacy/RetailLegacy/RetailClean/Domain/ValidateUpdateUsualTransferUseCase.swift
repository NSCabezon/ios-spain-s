import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ValidateUpdateUsualTransferUseCase: UseCase<ValidateUpdateUsualTransferUseCaseInput, ValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ValidateUpdateUsualTransferUseCaseInput) throws -> UseCaseResponse<ValidateUpdateUsualTransferUseCaseOkOutput, StringErrorOutput> {
        let favorite = requestValues.favourite.representable
        let currencyDTO = requestValues.newCurrency?.currency.currencyDTO
        let ibanDTO = requestValues.newDestinationAccount?.ibanDTO
        let response = try provider.getBsanTransfersManager().validateUpdateSepaPayee(payeeId: nil, payee: favorite, newCurrencyDTO: currencyDTO, newBeneficiaryBAOName: requestValues.newBeneficiaryName, newIban: ibanDTO)
        guard response.isSuccess(),
            let signatureWithTokenDTO = try response.getResponseData(),
            let signatureWithToken = SignatureWithToken(dto: signatureWithTokenDTO)
            else {
                let errorDescription = try response.getErrorMessage() ?? ""
                return UseCaseResponse.error(StringErrorOutput(errorDescription))
        }
        return UseCaseResponse.ok(ValidateUpdateUsualTransferUseCaseOkOutput(signatureWithToken: signatureWithToken))
    }
}

struct ValidateUpdateUsualTransferUseCaseInput {
    let favourite: Favourite
    let newBeneficiaryName: String?
    let newDestinationAccount: IBAN?
    let newCurrency: SepaCurrencyInfo?
}

struct ValidateUpdateUsualTransferUseCaseOkOutput {
    let signatureWithToken: SignatureWithToken
}
