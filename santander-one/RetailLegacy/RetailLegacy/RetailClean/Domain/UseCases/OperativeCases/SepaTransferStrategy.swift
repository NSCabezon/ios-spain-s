import CoreFoundationLib
import SANLegacyLibrary
import Foundation

protocol GenericSepaTransferStrategy: TransferStrategy {}

/// Represents a sepa transfer strategy
struct SepaTransferStrategy: GenericSepaTransferStrategy {
    let provider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    var dependenciesResolver: DependenciesResolver

    
    func validateDestinationAccount(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        switch ibanValidation(requestValues: requestValues) {
        case .ok(let okOutput):
            let input = GenericTransferInputDTO(
                beneficiary: requestValues.name,
                isSpanishResident: requestValues.isSpanishResident,
                ibandto: okOutput.ibanDTO,
                saveAsUsual: requestValues.saveFavorites,
                saveAsUsualAlias: requestValues.alias,
                beneficiaryMail: nil,
                amountDTO: requestValues.amount.amountDTO,
                concept: requestValues.concept,
                transferType: .INTERNATIONAL_SEPA_TRANSFER,
                tokenPush: nil
            )
            let response = try provider.getBsanTransfersManager().validateGenericTransfer(originAccountDTO: requestValues.originAccount.accountDTO, nationalTransferInput: input)
            guard response.isSuccess(), let data = try response.getResponseData(), let transferNationalDTO = data.transferNationalDTO else {
                let errorDesc = try response.getErrorMessage()
                return UseCaseResponse.error(DestinationAccountOnePayTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDesc)))
            }
            return UseCaseResponse.ok(DestinationAccountOnePayTransferUseCaseOkOutput(iban: okOutput, name: requestValues.name ?? "", alias: requestValues.alias, saveFavorites: requestValues.saveFavorites, time: requestValues.time, transferNational: TransferNational(dto: transferNationalDTO), scheduledTransfer: nil))
        case .error(let errorOutput):
            return .error(errorOutput)
        }
    }
    
    func validateTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail, !beneficiaryMail.isEmpty, !beneficiaryMail.isValidEmail() {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let genericTransferDTO = GenericTransferInputDTO(
            beneficiary: requestValues.name,
            isSpanishResident: requestValues.isSpanishResident,
            ibandto: requestValues.destinationIBAN.ibanDTO,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            beneficiaryMail: requestValues.beneficiaryMail,
            amountDTO: requestValues.amount.amountDTO,
            concept: requestValues.concept,
            transferType: .INTERNATIONAL_SEPA_TRANSFER,
            tokenPush: nil
        )
        let response = try self.validateSepaTransfer(originAccountDTO: requestValues.originAccount.accountDTO, genericTransferDTO: genericTransferDTO)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDescription)))
        }
        guard let responseData = try response.getResponseData(), let transferNationalDTO = responseData.transferNationalDTO else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let transferNational = TransferNational(dto: transferNationalDTO)
        guard let scaRepresentable = transferNational.scaRepresentable else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let scaEntity = LegacySCAEntity(scaRepresentable)
        return UseCaseResponse.ok(ValidateOnePayTransferUseCaseOkOutput(transferNational: transferNational, beneficiaryMail: requestValues.beneficiaryMail, scaEntity: scaEntity))
    }
    
    func confirmTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager = provider.getBsanTransfersManager()
        let input = GenericTransferInputDTO(
            beneficiary: requestValues.name,
            isSpanishResident: requestValues.isSpanishResident,
            ibandto: requestValues.destinationIBAN.ibanDTO,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            beneficiaryMail: requestValues.beneficiaryMail,
            amountDTO: requestValues.amount.amountDTO,
            concept: requestValues.concept,
            transferType: .INTERNATIONAL_SEPA_TRANSFER,
            tokenPush: nil
        )
        let response = try manager.confirmGenericTransfer(originAccountDTO: requestValues.originAccount.accountDTO, nationalTransferInput: input, otpValidationDTO: requestValues.otpValidation?.otpValidationDTO, otpCode: requestValues.code, trusteerInfo: trusteerInfo)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        let transferConfirmAccount = TransferConfirmAccount(dto: data)
        return UseCaseResponse.ok(ConfirmOtpOnePayTransferUseCaseOkOutput(transferConfirmAccount: transferConfirmAccount))
    }
    
    //This method is empty until SantanderKey could confirm sepa transfers
    func validateSanKeyTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        return .error(ValidateTransferUseCaseErrorOutput(ValidateTransferError.serviceError(errorDesc: "Aún no se puede implementar SantanderKey en esta strategy")))
    }
    
    func confirmSanKeyTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return .error(GenericErrorSignatureErrorOutput("Aún no se puede implementar SantanderKey en esta strategy", .otherError, ""))
    }
    
    func confirmSanKeyTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return .error(GenericErrorOTPErrorOutput("Aún no se puede implementar SantanderKey en esta strategy", OTPResult.otherError(errorDesc: ""), ""))
    }
}

extension TransferStrategy where Self: GenericSepaTransferStrategy {
    
    func ibanValidation(requestValues: IBANValidable) -> IBANValidationResult {
        guard let ibanString = requestValues.iban else {
            return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.ibanInvalid))
        }
        let iban = IBAN.create(fromText: ibanString)
        return .ok(iban)
    }
}

private extension SepaTransferStrategy {
    func validateSepaTransfer(originAccountDTO: AccountDTO, genericTransferDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        guard let validateSepaTransferModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayNationalSepaValidationModifierProtocol.self) else {
            return try provider.getBsanTransfersManager().validateGenericTransfer(originAccountDTO: originAccountDTO, nationalTransferInput: genericTransferDTO)
        }
        return try validateSepaTransferModifier.validateGenericTransfer(originAccountDTO: originAccountDTO, nationalTransferInput: genericTransferDTO)
    }
}

public protocol OnePayNationalSepaValidationModifierProtocol {
    func validateGenericTransfer(originAccountDTO: AccountDTO,
        nationalTransferInput: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO>
}
