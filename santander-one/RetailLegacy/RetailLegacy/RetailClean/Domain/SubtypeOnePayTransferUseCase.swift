import CoreFoundationLib
import SANLegacyLibrary

class SubtypeOnePaySanKeyTransferUseCase: SubtypeTransferUseCase<SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, ValidateAccountTransferDTO> {
    override func executeValidateTransfer(requestValues: SubtypeOnePayTransferUseCaseInput,
                                          inputDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        let transferManger = provider.getBsanTransfersManager()
        return try transferManger.validateSanKeyTransfer(
            originAccountDTO: requestValues.originAccount.accountDTO,
            nationalTransferInput: inputDTO
        )
    }
    
    override func proccessResponse(output: ValidateAccountTransferDTO) throws -> UseCaseResponse<SubtypeOnePayTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        guard let transferNationalDTO = output.transferNationalDTO else {
            return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let transferNational = TransferNational(dto: transferNationalDTO)
        return UseCaseResponse.ok(SubtypeOnePayTransferUseCaseOkOutput(transferNational: transferNational))
    }
}

class SubtypeOnePayTransferUseCase: SubtypeTransferUseCase<SubtypeOnePayTransferUseCaseInput, SubtypeOnePayTransferUseCaseOkOutput, ValidateAccountTransferDTO> {
    override func executeValidateTransfer(requestValues: SubtypeOnePayTransferUseCaseInput, inputDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        let transferManger = provider.getBsanTransfersManager()
        return try transferManger.validateGenericTransfer(originAccountDTO: requestValues.originAccount.accountDTO, nationalTransferInput: inputDTO)
    }
    
    override func proccessResponse(output: ValidateAccountTransferDTO) throws -> UseCaseResponse<SubtypeOnePayTransferUseCaseOkOutput, SubtypeTransferUseCaseErrorOutput> {
        guard let transferNationalDTO = output.transferNationalDTO else {
            return UseCaseResponse.error(SubtypeTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let transferNational = TransferNational(dto: transferNationalDTO)
        return UseCaseResponse.ok(SubtypeOnePayTransferUseCaseOkOutput(transferNational: transferNational))
    }
}

struct SubtypeOnePayTransferUseCaseInput {
    let originAccount: Account
    let amount: Amount
    let maxAmount: Amount?
    let subtype: OnePayTransferSubType
    let type: OnePayTransferType
    let beneficiary: String?
    let isSpanishResident: Bool
    let iban: IBAN
    let saveAsUsual: Bool
    let saveAsUsualAlias: String?
    let concept: String?
    var tokenPush: String?
}

struct SubtypeOnePayTransferUseCaseOkOutput {
    let transferNational: TransferNational
}

extension SubtypeOnePayTransferUseCaseInput: SubtypeTransferUseCaseInput {
    var beneficiaryMail: String? {
        return nil
    }
    var alias: String? {
        return saveAsUsualAlias
    }
}
extension ValidateAccountTransferDTO: ValidateTransferProtocol {}
