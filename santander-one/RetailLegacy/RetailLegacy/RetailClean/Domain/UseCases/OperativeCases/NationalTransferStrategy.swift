import Foundation
import SANLegacyLibrary
import CoreFoundationLib

protocol GenericNationalTransferStrategy: TransferStrategy {}

/// Represents a national transfer strategy
struct NationalTransferStrategy: GenericNationalTransferStrategy {
    
    let provider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    var trusteerRepository: TrusteerRepositoryProtocol
    let dependenciesResolver: DependenciesResolver

    func validateDestinationAccount(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        switch ibanValidation(requestValues: requestValues) {
        case .ok(let okOutput): return .ok(DestinationAccountOnePayTransferUseCaseOkOutput(iban: okOutput, name: requestValues.name ?? "", alias: requestValues.alias, saveFavorites: requestValues.saveFavorites, time: requestValues.time, transferNational: nil, scheduledTransfer: nil))
        case .error(let errorOutput): return .error(errorOutput)
        }
    }
    
    // MARK: - Confirm Transfer
    
    func confirmTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let transferManger = provider.getBsanTransfersManager()
        let input = getNationalTransferInput(from: requestValues)
        guard let signature = requestValues.signature?.dto else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try transferManger.validateGenericTransferOTP(originAccountDTO: requestValues.originAccount.accountDTO,
                                                                     nationalTransferInput: input,
                                                                     signatureDTO: signature)
        
        let signatureType = try getSignatureResult(response)
        if let otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationOTP))
                return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }

    func confirmSanKeyTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let transferManger = provider.getBsanTransfersManager()
        let input = getNationalTransferInput(from: requestValues)
        let signature = requestValues.signature
        let response = try transferManger.validateSanKeyTransferOTP(originAccountDTO: requestValues.originAccount.accountDTO,
                                                                    nationalTransferInput: input,
                                                                    signatureDTO: signature?.dto,
                                                                    tokenSteps: requestValues.tokenSteps ?? "",
                                                                    footPrint: requestValues.footPrint,
                                                                    deviceToken: requestValues.deviceToken)
        
        let signatureType = try getSignatureResult(response)
        if let sanKeyOtpValidationOTP = try? response.getResponseData(),
           let otpValidationDTO = sanKeyOtpValidationOTP.otpValidationDTO {
            switch signatureType {
            case .ok:
                if let ticket = otpValidationDTO.ticket, ticket.isEmpty || otpValidationDTO.ticket == nil {
                    let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationDTO))
                    return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp, sanKeyOTP: sanKeyOtpValidationOTP))
                } else {
                    let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationDTO))
                    return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp, sanKeyOTP: sanKeyOtpValidationOTP))
                }
            case .otpUserExcepted:
                let otp = OTP.userExcepted(OTPValidation(otpValidationDTO: otpValidationDTO))
                return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp, sanKeyOTP: sanKeyOtpValidationOTP))
            default:
                let otp = OTP.validation(OTPValidation(otpValidationDTO: otpValidationDTO))
                return UseCaseResponse.ok(ConfirmOnePayTransferUseCaseOkOutput(otp: otp, sanKeyOTP: sanKeyOtpValidationOTP))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
    
    private func getNationalTransferInput(from requestValues: ConfirmOnePayTransferUseCaseInput) -> NationalTransferInput {
        NationalTransferInput(beneficiary: requestValues.beneficiary,
                                          isSpanishResident: requestValues.isSpanishResident,
                                          ibandto: requestValues.iban.ibanDTO,
                                          saveAsUsual: requestValues.saveAsUsual,
                                          saveAsUsualAlias: requestValues.saveAsUsualAlias,
                                          beneficiaryMail: requestValues.beneficiaryMail,
                                          amountDTO: requestValues.amount.amountDTO,
                                          concept: requestValues.concept)
    }
    
    // MARK: - Validate Transfer
    
    func validateTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail,
           !isValidEmail(email: beneficiaryMail) {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let genericTransferDTO = getGenericTransferInput(from: requestValues)
        let response = try self.validateSepaTransfer(originAccountDTO: requestValues.originAccount.accountDTO,
                                                     genericTransferDTO: genericTransferDTO)
        
        return try processValidateTransferResponse(response, beneficiaryMail: requestValues.beneficiaryMail)
    }
        
    func validateSanKeyTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail,
           !isValidEmail(email: beneficiaryMail) {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let genericTransferDTO = getGenericTransferInput(from: requestValues)
        let response = try self.validateSepaSanKeyTransfer(originAccountDTO: requestValues.originAccount.accountDTO,
                                                           genericTransferDTO: genericTransferDTO)
        return try processValidateTransferResponse(response, beneficiaryMail: requestValues.beneficiaryMail)
    }
    
    private func isValidEmail(email: String) -> Bool {
        return !email.isEmpty && email.isValidEmail()
    }
    
    private func getTransferTypeDTO(from type: OnePayTransferSubType?) -> TransferTypeDTO {
        switch type {
        case .immediate?:
            return .NATIONAL_INSTANT_TRANSFER
        case .urgent?:
            return .NATIONAL_URGENT_TRANSFER
        case .standard?, .none:
            return .NATIONAL_TRANSFER
        }
    }
    
    private func getGenericTransferInput(from requestValues: ValidateOnePayTransferUseCaseInput) -> GenericTransferInputDTO {
        GenericTransferInputDTO(
            beneficiary: requestValues.name,
            isSpanishResident: requestValues.isSpanishResident,
            ibandto: requestValues.destinationIBAN.ibanDTO,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            beneficiaryMail: requestValues.beneficiaryMail,
            amountDTO: requestValues.amount.amountDTO,
            concept: requestValues.concept,
            transferType: getTransferTypeDTO(from: requestValues.subType),
            tokenPush: requestValues.tokenPush
        )
    }
    
    private func processValidateTransferResponse(_ response: BSANResponse<ValidateAccountTransferDTO>,
                                                 beneficiaryMail: String?) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDescription)))
        }
        guard let responseData = try response.getResponseData(),
              let transferNationalDTO = responseData.transferNationalDTO
        else { return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))}
        let transferNational = TransferNational(dto: transferNationalDTO)
        guard let scaRepresentale = transferNational.scaRepresentable
        else { return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))}
        let scaEntity = LegacySCAEntity(scaRepresentale)
        return UseCaseResponse.ok(
            ValidateOnePayTransferUseCaseOkOutput(
                transferNational: transferNational,
                beneficiaryMail: beneficiaryMail,
                scaEntity: scaEntity)
        )
    }
    
    // MARK: - Confirm Transfer OTP
    
    func confirmTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager = provider.getBsanTransfersManager()
        let input = getConfirmTransferOTPInput(from: requestValues)
        let response = try manager.confirmGenericTransfer(
            originAccountDTO: requestValues.originAccount.accountDTO,
            nationalTransferInput: input,
            otpValidationDTO: requestValues.otpValidation?.otpValidationDTO,
            otpCode: requestValues.code,
            trusteerInfo: self.trusteerInfo
        )
        return try processConfirmTransferOTPResponse(response)
    }
    
    func confirmSanKeyTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager = provider.getBsanTransfersManager()
        let input = getConfirmTransferOTPInput(from: requestValues)
        guard let tokenSteps = requestValues.tokenSteps else {
            return .error(GenericErrorOTPErrorOutput(nil, .otherError(errorDesc: "no tokenSteps"), nil))
        }
        let response = try manager.confirmSanKeyTransfer(
            originAccountDTO: requestValues.originAccount.accountDTO,
            nationalTransferInput: input,
            otpValidationDTO: requestValues.otpValidation?.otpValidationDTO,
            otpCode: requestValues.code,
            trusteerInfo: self.trusteerInfo,
            tokenSteps: tokenSteps
        )
        return try processConfirmTransferOTPResponse(response)
    }
    
    private func processConfirmTransferOTPResponse(_ response: BSANResponse<TransferConfirmAccountDTO>) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        let transferConfirmAccount = TransferConfirmAccount(dto: data)
        return UseCaseResponse.ok(ConfirmOtpOnePayTransferUseCaseOkOutput(transferConfirmAccount: transferConfirmAccount))
    }
    
    private func getConfirmTransferOTPInput(from requestValues: ConfirmOtpOnePayTransferUseCaseInput) -> GenericTransferInputDTO {
        GenericTransferInputDTO(
            beneficiary: requestValues.name,
            isSpanishResident: requestValues.isSpanishResident,
            ibandto: requestValues.destinationIBAN.ibanDTO,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            beneficiaryMail: requestValues.beneficiaryMail,
            amountDTO: requestValues.amount.amountDTO,
            concept: requestValues.concept,
            transferType: getTransferTypeDTO(from: requestValues.subType),
            tokenPush: nil
        )
    }
}

// MARK: - EXTENSIONS

extension TransferStrategy where Self: GenericNationalTransferStrategy {
    
    func ibanValidation(requestValues: IBANValidable) -> IBANValidationResult {
        guard let ibanString = requestValues.iban, bankingUtils.isValidIban(ibanString: ibanString) else {
            return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.ibanInvalid))
        }
        
        let iban = IBAN.create(fromText: ibanString)
        return .ok(iban)
    }
}

private extension NationalTransferStrategy {
    func validateSepaTransfer(originAccountDTO: AccountDTO, genericTransferDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        guard let validateSepaTransferModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayNationalSepaValidationModifierProtocol.self) else {
            return try provider.getBsanTransfersManager()
                .validateGenericTransfer(originAccountDTO: originAccountDTO,
                                         nationalTransferInput: genericTransferDTO)
        }
        return try validateSepaTransferModifier.validateGenericTransfer(originAccountDTO: originAccountDTO,
                                                                        nationalTransferInput: genericTransferDTO)
    }
    
    func validateSepaSanKeyTransfer(originAccountDTO: AccountDTO, genericTransferDTO: GenericTransferInputDTO) throws -> BSANResponse<ValidateAccountTransferDTO> {
        return try provider.getBsanTransfersManager()
            .validateSanKeyTransfer(originAccountDTO: originAccountDTO,
                                     nationalTransferInput: genericTransferDTO)
    }
}
