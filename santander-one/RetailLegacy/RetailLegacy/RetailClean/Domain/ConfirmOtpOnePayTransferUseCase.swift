import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOtpOnePayTransferUseCase: UseCase<ConfirmOtpOnePayTransferUseCaseInput, ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider,
         appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol,
         dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOtpOnePayTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let type = TransferStrategyType.transferType(type: requestValues.type,
                                                     time: requestValues.time)
        let strategy = type.strategy(provider: provider,
                                     appConfigRepository: appConfigRepository,
                                     trusteerRepository: trusteerRepository,
                                     dependenciesResolver: self.dependenciesResolver)
        return try strategy.confirmTransferOTP(requestValues: requestValues)
    }
}

struct ConfirmOtpOnePayTransferUseCaseInput: ScheduledTransferConvertible {
    var otpValidation: OTPValidation?
    let code: String
    let type: OnePayTransferType
    let subType: OnePayTransferSubType
    let originAccount: Account
    let destinationIBAN: IBAN
    let name: String?
    let alias: String?
    let isSpanishResident: Bool
    let saveFavorites: Bool
    let beneficiaryMail: String?
    let amount: Amount
    let concept: String?
    let time: OnePayTransferTime
    let scheduledTransfer: ScheduledTransfer?
    var tokenSteps: String? = nil
}

struct ConfirmOtpOnePayTransferUseCaseOkOutput {
    let transferConfirmAccount: TransferConfirmAccount?
}
