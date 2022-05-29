import CoreFoundationLib
import Foundation
import SANLegacyLibrary

enum TransferStrategyType {
    case national
    case periodicNational
    case deferredNational
    case sepa
    case periodicSepa
    case deferredSepa
    
    static func transferType(type: OnePayTransferType, time: OnePayTransferTime) -> TransferStrategyType {
        let transferType: TransferStrategyType
        switch type {
        case .national:
            switch time {
            case .now: transferType = .national
            case .day: transferType = .deferredNational
            case .periodic: transferType = .periodicNational
            }
        case .sepa:
            switch time {
            case .now: transferType = .sepa
            case .day: transferType = .deferredSepa
            case .periodic: transferType = .periodicSepa
            }
        case .noSepa:
            fatalError()
        }
        return transferType
    }
    
    func strategy(provider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) -> TransferStrategy {
        switch self {
        case .national:
            return NationalTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        case .periodicNational:
            return NationalPeriodicTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        case .deferredNational:
            return NationalDeferredTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        case .deferredSepa:
            return SepaDeferredTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        case .sepa:
            return SepaTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        case .periodicSepa:
            return SepaPeriodicTransferStrategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: dependenciesResolver)
        }
    }
}

enum IBANValidationResult {
    case ok(IBAN)
    case error(DestinationAccountOnePayTransferUseCaseErrorOutput)
}

protocol IBANValidable {
    var iban: String? { get }
    var country: SepaCountryInfo { get }
}

protocol TransferStrategy {
    
    var provider: BSANManagersProvider { get }
    var appConfigRepository: AppConfigRepository { get }
    var trusteerRepository: TrusteerRepositoryProtocol { get }
    var dependenciesResolver: DependenciesResolver { get }
    /// Method called to validate the iban
    func ibanValidation(requestValues: IBANValidable) -> IBANValidationResult
    
    /// Method called from DestinationAccountUseCase. It is use to validate destination account.
    func validateDestinationAccount(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput>
    
    /// Method called from ValidateUseCase. It is use to validate transfer data.
    func validateTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput>
    
    func validateSanKeyTransfer(requestValues: ValidateOnePayTransferUseCaseInput) throws -> UseCaseResponse<ValidateOnePayTransferUseCaseOkOutput, ValidateTransferUseCaseErrorOutput>
    
    /// Method called from ConfirmUseCase. It is use to confirm the transfer with the signature
    func confirmTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput>
    
    func confirmSanKeyTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput>
    
    /// Method called from ConfirmOTPUseCase. It is use to confirm the transfer with the OTP
    func confirmTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput>
    
    func confirmSanKeyTransferOTP(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput>
}

extension TransferStrategy {
    internal var bankingUtils: BankingUtilsProtocol {
        return dependenciesResolver.resolve()
    }
    
    func preValidateDestinationAccount(requestValues: DestinationAccountOnePayTransferUseCaseInput) throws -> UseCaseResponse<DestinationAccountOnePayTransferUseCaseOkOutput, DestinationAccountOnePayTransferUseCaseErrorOutput> {
        guard let ibanString = requestValues.iban, !ibanString.isEmpty, bankingUtils.isValidIban(ibanString: ibanString) else {
            return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.ibanInvalid))
        }
        
        guard let name = requestValues.name, name.trim().count > 0 else {
            return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.noToName))
        }
        if requestValues.saveFavorites {
            guard let alias = requestValues.alias, alias.trim().count > 0 else {
                return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.noAlias))
            }
            let duplicate = requestValues.favouriteList.first { return $0.baoName?.trim() == alias.trim() }
            guard duplicate == nil else {
                return .error(DestinationAccountOnePayTransferUseCaseErrorOutput(.duplicateAlias(alias: alias)))
            }
        }
        return try validateDestinationAccount(requestValues: requestValues)
    }
    
    func confirmTransfer(requestValues: ConfirmOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOnePayTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let transferManger = provider.getBsanTransfersManager()
        let input = NationalTransferInput(beneficiary: requestValues.beneficiary,
                                          isSpanishResident: requestValues.isSpanishResident,
                                          ibandto: requestValues.iban.ibanDTO,
                                          saveAsUsual: requestValues.saveAsUsual,
                                          saveAsUsualAlias: requestValues.saveAsUsualAlias,
                                          beneficiaryMail: requestValues.beneficiaryMail,
                                          amountDTO: requestValues.amount.amountDTO,
                                          concept: requestValues.concept)
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
}

extension TransferStrategy {

    var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessionId = trusteerRepository.appSessionId,
            self.appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true,
            self.appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfers) == true
        else {
            return nil
        }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfigRepository)
    }
}
