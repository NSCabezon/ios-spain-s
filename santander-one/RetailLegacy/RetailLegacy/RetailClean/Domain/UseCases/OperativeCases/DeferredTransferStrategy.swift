import CoreFoundationLib
import SANLegacyLibrary
import Foundation

protocol GenericDeferredTransferStrategy: TransferStrategy {}

/// Represents a national transfer strategy with a deferred transfer
struct NationalDeferredTransferStrategy: GenericNationalTransferStrategy, GenericDeferredTransferStrategy {
    let provider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    let dependenciesResolver: DependenciesResolver

}

/// Represents a sepa transfer strategy with a deferred transfer
struct SepaDeferredTransferStrategy: GenericSepaTransferStrategy, GenericDeferredTransferStrategy {
    let provider: BSANManagersProvider
    let appConfigRepository: AppConfigRepository
    let trusteerRepository: TrusteerRepositoryProtocol
    let dependenciesResolver: DependenciesResolver
}

extension GenericDeferredTransferStrategy {
    
    // MARK: - Private methods
    
    private func validateDeferredTransfer<Input: ScheduledTransferConvertible>(requestValues: Input, iban: IBAN, subType: TransferTypeDTO? = nil) throws -> BSANResponse<ValidateScheduledTransferDTO> {
        guard case .day(date: let date) = requestValues.time else {
            fatalError()
        }
        let transferDTO = requestValues.toScheduledTransferInputDTO(date: date, iban: iban, subType: subType)
        let response = try provider.getBsanTransfersManager().validateDeferredTransfer(originAcount: requestValues.originAccount.accountDTO, scheduledTransferInput: transferDTO)
        return response
    }
    
    private var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessionId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersDeferred) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfigRepository)
    }
    
    // MARK: - Overrided methods
    
    func validateDestinationAccount(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        switch ibanValidation(requestValues: requestValues) {
        case .ok(let okOutput):
            guard let mustValidateDestinationAccount = self.dependenciesResolver.resolve(forOptionalType: OnePayPeriodicTransferModifierProtocol.self)?.mustValidateDestinationAccount,
                  !mustValidateDestinationAccount else {
                let response = try validateDeferredTransfer(requestValues: requestValues, iban: okOutput)
                guard response.isSuccess() else {
                    let errorDescription = try response.getErrorMessage()
                    return UseCaseResponse.error(DestinationAccountOnePayTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDescription)))
                }
                guard let responseData = try response.getResponseData() else {
                    return UseCaseResponse.error(DestinationAccountOnePayTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
                }
                return UseCaseResponse.ok(DestinationAccountOnePayTransferUseCaseOkOutput(iban: okOutput, name: requestValues.name ?? "", alias: requestValues.alias, saveFavorites: requestValues.saveFavorites, time: requestValues.time, transferNational: nil, scheduledTransfer: ScheduledTransfer(dto: responseData)))
            }
            return UseCaseResponse.ok(DestinationAccountOnePayTransferUseCaseOkOutput(iban: okOutput, name: requestValues.name ?? "", alias: requestValues.alias, saveFavorites: requestValues.saveFavorites, time: requestValues.time, transferNational: nil, scheduledTransfer: nil))
        case .error(let errorOutput):
            return .error(errorOutput)
        }
    }
    
    func validateTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail, !beneficiaryMail.isEmpty, !beneficiaryMail.isValidEmail() {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let transferTypeDTO: TransferTypeDTO = self.getTransferType(forSubtype: requestValues.subType)
        let response = try validateDeferredTransfer(requestValues: requestValues, iban: requestValues.destinationIBAN, subType: transferTypeDTO)
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: errorDescription)))
        }
        guard let responseData = try response.getResponseData() else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        guard let scaRepresentable = responseData.scaRepresentable else {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
        }
        let scaEntity = LegacySCAEntity(scaRepresentable)
        return UseCaseResponse.ok(ValidateOnePayTransferUseCaseOkOutput(scheduledTransfer: ScheduledTransfer(dto: responseData), beneficiaryMail: requestValues.beneficiaryMail, scaEntity: scaEntity))
    }
    
    func confirmTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature?.dto else {
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try provider.getBsanTransfersManager().validateDeferredTransferOTP(signatureDTO: signature,
                                                                                          dataToken: requestValues.dataMagicPhrase ?? "")
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
    
    func confirmTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        guard case .day(date: let date) = requestValues.time, let otpValidation = requestValues.otpValidation else {
            return .error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        let transferTypeDTO: TransferTypeDTO = self.getTransferType(forSubtype: requestValues.subType)
        let code = requestValues.code
        let response = try provider.getBsanTransfersManager().confirmDeferredTransfer(
            originAccountDTO: requestValues.originAccount.accountDTO,
            scheduledTransferInput: requestValues.toScheduledTransferInputDTO(
                date: date,
                iban: requestValues.destinationIBAN,
                subType: transferTypeDTO
            ),
            otpValidationDTO: otpValidation.otpValidationDTO,
            otpCode: code,
            trusteerInfo: trusteerInfo
        )
        if response.isSuccess() {
            return .ok(ConfirmOtpOnePayTransferUseCaseOkOutput(transferConfirmAccount: nil))
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
    
    func validateSanKeyTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput> {
        return .error(ValidateTransferUseCaseErrorOutput(ValidateTransferError.serviceError(errorDesc: "This Strategy should not implement Santander Key yet")))
    }
    
    func confirmSanKeyTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        return .error(GenericErrorSignatureErrorOutput("This Strategy should not implement Santander Key yet", .otherError, ""))
    }
    
    func confirmSanKeyTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        return .error(GenericErrorOTPErrorOutput("This Strategy should not implement Santander Key yet", OTPResult.otherError(errorDesc: ""), ""))
    }
}

private extension GenericDeferredTransferStrategy {
    func getTransferType(forSubtype subType: OnePayTransferSubType?) -> TransferTypeDTO {
        switch subType {
        case .immediate:
            return .NATIONAL_INSTANT_TRANSFER
        case .urgent:
            return  .NATIONAL_URGENT_TRANSFER
        case .standard, .none:
            return .NATIONAL_TRANSFER
        }
    }
}
