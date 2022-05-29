import CoreFoundationLib
import SANLegacyLibrary

class SubtypeUsualTransferUseCase: SubtypeTransferUseCase<SubtypeUsualTransferUseCaseInput, SubtypeUsualTransferUseCaseOkOutput, ValidateAccountTransferDTO> {
    override func executeValidateTransfer(requestValues: SubtypeUsualTransferUseCaseInput, inputDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        let transferManger = provider.getBsanTransfersManager()
        let typeDTO = getTransferTypeDTO(from: requestValues.type, and: requestValues.subtype)
        let input = UsualTransferInput(amountDTO: requestValues.amount.amountDTO, concept: requestValues.concept ?? "", beneficiaryMail: "", transferType: typeDTO)
        return try transferManger.validateUsualTransfer(originAccountDTO: requestValues.originAccount.accountDTO, usualTransferInput: input, payee: requestValues.favourite.representable)
    }
    
    override func proccessResponse(output: ValidateAccountTransferDTO) throws -> UseCaseResponse<SubtypeUsualTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        guard let transferNationalDTO = output.transferNationalDTO else {
            return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let transferNational = TransferNational(dto: transferNationalDTO)
        return UseCaseResponse.ok(SubtypeUsualTransferUseCaseOkOutput(transferNational: transferNational))
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

struct SubtypeUsualTransferUseCaseInput {
    let originAccount: Account
    let amount: Amount
    let maxAmount: Amount?
    let subtype: OnePayTransferSubType
    let type: OnePayTransferType
    let concept: String?
    let favourite: Favourite
}

struct SubtypeUsualTransferUseCaseOkOutput {
    let transferNational: TransferNational
}

extension SubtypeUsualTransferUseCaseInput: SubtypeTransferUseCaseInput {
    var beneficiary: String? {
        return favourite.alias
    }
    var beneficiaryMail: String? {
        return nil
    }   
    var isSpanishResident: Bool {
        return false
    }
    var iban: IBAN {
        return favourite.iban ?? IBAN.createEmpty()
    }
    var saveAsUsual: Bool {
        return false
    }
    var alias: String? {
        return nil
    }
    
    var tokenPush: String? { nil }
}
