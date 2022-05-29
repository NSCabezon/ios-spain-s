import SANLegacyLibrary
import CoreFoundationLib

class ConfirmOtpOnePaySanKeyTransferUseCase: UseCase<ConfirmOtpOnePayTransferUseCaseInput, ConfirmOtpOnePayTransferUseCaseOkOutput, GenericErrorOTPErrorOutput> {
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
        let type = TransferStrategyType.transferType(
            type: requestValues.type,
            time: requestValues.time
        )
        let strategy = type.strategy(
            provider: provider,
            appConfigRepository: appConfigRepository,
            trusteerRepository: trusteerRepository,
            dependenciesResolver: self.dependenciesResolver
        )
        return try strategy.confirmSanKeyTransferOTP(requestValues: requestValues)
    }
}
