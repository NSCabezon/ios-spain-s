import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class ConfirmOTPInternalScheduledTransferUseCase: UseCase<ConfirmOTPInternalScheduledTransferUseCaseInput, ConfirmOTPInternalScheduledTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    private let dependenciesResolver: DependenciesResolver
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository,
         trusteerRepository: TrusteerRepositoryProtocol, dependenciesResolver: DependenciesResolver) {
        self.provider = managersProvider
        self.appConfigRepository = appConfigRepository
        self.trusteerRepository = trusteerRepository
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOTPInternalScheduledTransferUseCaseInput) throws -> UseCaseResponse<ConfirmOTPInternalScheduledTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        
        let type = TransferStrategyType.transferType(type: .national, time: requestValues.transferTime)
        let strategy = type.strategy(provider: provider, appConfigRepository: appConfigRepository, trusteerRepository: trusteerRepository, dependenciesResolver: self.dependenciesResolver)
        
        guard let iban = requestValues.destinationAccount.getIban() else {
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(nil, .serviceDefault, nil))
        }
        
        let input = ConfirmOtpOnePayTransferUseCaseInput(
            otpValidation: requestValues.otpValidation,
            code: requestValues.code ?? "",
            type: .national,
            subType: .standard,
            originAccount: requestValues.originAccount,
            destinationIBAN: iban,
            name: "Lucas grijander",
            alias: "",
            isSpanishResident: true,
            saveFavorites: false,
            beneficiaryMail: "",
            amount: requestValues.amount,
            concept: requestValues.concept,
            time: requestValues.transferTime,
            scheduledTransfer: requestValues.scheduledTransfer
        )
        
        let response = try strategy.confirmTransferOTP(requestValues: input)
        guard response.isOkResult else {
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(try response.getErrorResult().getErrorDesc(), try response.getErrorResult().otpResult, try response.getErrorResult().errorCode))
        }
        return UseCaseResponse.ok(ConfirmOTPInternalScheduledTransferUseCaseOkOutput())
    }
}

struct ConfirmOTPInternalScheduledTransferUseCaseInput {
    let otpValidation: OTPValidation?
    let code: String?
    let originAccount: Account
    let destinationAccount: Account
    let amount: Amount
    let concept: String
    let transferTime: OnePayTransferTime
    let scheduledTransfer: ScheduledTransfer
}

struct ConfirmOTPInternalScheduledTransferUseCaseOkOutput {
}
