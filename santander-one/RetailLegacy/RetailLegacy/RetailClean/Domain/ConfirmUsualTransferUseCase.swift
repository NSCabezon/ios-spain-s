import SANLegacyLibrary
import CoreFoundationLib

class ConfirmUsualTransferUseCase: ConfirmUseCase<ConfirmUsualTransferUseCaseInput, ConfirmUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: ConfirmUsualTransferUseCaseInput) throws -> UseCaseResponse<ConfirmUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        switch requestValues.type {
        case .national, .sepa:
            return try sepaTransfer(requestValues: requestValues)
        case .noSepa:
            return try noSepaTransfer(requestValues: requestValues)
        }
    }
    
    private func sepaTransfer(requestValues: ConfirmUsualTransferUseCaseInput) throws -> UseCaseResponse<ConfirmUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let transferManger = provider.getBsanTransfersManager()
        let typeDTO = getTransferTypeDTO(from: requestValues.type, and: requestValues.subtype)
        let input = UsualTransferInput(amountDTO: requestValues.amount.amountDTO, concept: requestValues.concept ?? "", beneficiaryMail: requestValues.beneficiaryMail ?? "", transferType: typeDTO)
        let response = try transferManger.confirmUsualTransfer(originAccountDTO: requestValues.originAccount.accountDTO, usualTransferInput: input, payee: requestValues.favourite.representable, signatureDTO: requestValues.signature.dto)
        guard response.isSuccess() else {
            let signatureType = try getSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
         guard let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, .otherError, errorCode))
        }
        let transferConfirmAccount = TransferConfirmAccount(dto: data)
        return UseCaseResponse.ok(ConfirmUsualTransferUseCaseOkOutput(transferConfirmAccount: transferConfirmAccount))
    }
    
    private func noSepaTransfer(requestValues: ConfirmUsualTransferUseCaseInput) throws -> UseCaseResponse<ConfirmUsualTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        //TODO: Transferencias no sepa
        return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
    }
    
    private func getTransferTypeDTO(from type: OnePayTransferType, and subType: OnePayTransferSubType) -> TransferTypeDTO {
        switch type {
        case .national:
            switch subType {
            case .immediate: return .NATIONAL_INSTANT_TRANSFER
            case .urgent: return .NATIONAL_URGENT_TRANSFER
            case .standard: return .NATIONAL_TRANSFER
            }
        case .sepa: return .INTERNATIONAL_SEPA_TRANSFER
        default: return .USUAL_TRANSFER
        }
    }
}

struct ConfirmUsualTransferUseCaseInput {
    let signature: Signature
    let type: OnePayTransferType
    let subtype: OnePayTransferSubType
    let originAccount: Account
    let amount: Amount
    let favourite: Favourite
    let concept: String?
    let beneficiaryMail: String?
}

struct ConfirmUsualTransferUseCaseOkOutput {
    let transferConfirmAccount: TransferConfirmAccount
}
