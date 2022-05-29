import CoreFoundationLib
import SANLegacyLibrary

class ConfirmOtpWithdrawMoneyWithCodeUseCase: UseCase<ConfirmOtpWithdrawMoneyWithCodeUseCaseInput, ConfirmOtpWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfig: AppConfigRepository
    private let trusteerRepository: TrusteerRepositoryProtocol
    
    init(managersProvider: BSANManagersProvider, appConfigRepository: AppConfigRepository, trusteerRepository: TrusteerRepositoryProtocol) {
        self.provider = managersProvider
        self.appConfig = appConfigRepository
        self.trusteerRepository = trusteerRepository
    }
    
    var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessionId = trusteerRepository.appSessionId,
            appConfig.getBool(TrusteerConstants.appConfigEnableTrusteer) == true,
            appConfig.getBool(TrusteerConstants.appConfigEnableTrusteerWithdrawMoney) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfig)
    }
    
    override func executeUseCase(requestValues: ConfirmOtpWithdrawMoneyWithCodeUseCaseInput) throws -> UseCaseResponse<ConfirmOtpWithdrawMoneyWithCodeUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager = provider.getBsanCashWithdrawalManager()
        let cardDTO = requestValues.card.cardDTO
        let otpValidationDTO = requestValues.otpValidation?.otpValidationDTO
        let codeOTP = requestValues.code
        let amountDTO = requestValues.amount.amountDTO
        let response = try manager.confirmOTP(cardDTO: cardDTO, otpValidationDTO: otpValidationDTO, otpCode: codeOTP, amount: amountDTO, trusteerInfo: trusteerInfo)
        guard response.isSuccess(), let data = try response.getResponseData() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        var cashWithDrawal = CashWithDrawal(dto: data)
   
        if appConfig.getBool("enableWithdrawMoneyQR") == false {
            cashWithDrawal.codQR = nil
        }
        return UseCaseResponse.ok(ConfirmOtpWithdrawMoneyWithCodeUseCaseOkOutput(cashWithDrawal: cashWithDrawal))
    }
}

struct ConfirmOtpWithdrawMoneyWithCodeUseCaseInput {
    let card: Card
    let otpValidation: OTPValidation?
    let code: String?
    let amount: Amount
}

struct ConfirmOtpWithdrawMoneyWithCodeUseCaseOkOutput {
    let cashWithDrawal: CashWithDrawal
}
