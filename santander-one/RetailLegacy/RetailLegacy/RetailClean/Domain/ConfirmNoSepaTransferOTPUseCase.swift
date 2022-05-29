import CoreFoundationLib
import Foundation
import SANLegacyLibrary

class ConfirmNoSepaTransferOTPUseCase: UseCase<ConfirmNoSepaTransferOTPUseCaseInput, ConfirmNoSepaTransferOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let bsanManagersProvider: BSANManagersProvider
    private let trusteerRepository: TrusteerRepositoryProtocol
    init(appConfigRepository: AppConfigRepositoryProtocol, bsanManagersProvider: BSANManagersProvider,
         trusteerRepository: TrusteerRepositoryProtocol) {
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.trusteerRepository = trusteerRepository
    }
    
    var trusteerInfo: TrusteerInfoDTO? {
        guard
            let appSessionId = trusteerRepository.appSessionId,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteer) == true,
            appConfigRepository.getBool(TrusteerConstants.appConfigEnableTrusteerTransfersNoSepa) == true
        else { return nil }
        return TrusteerInfoProvider.getTrusteerInfoWithCustomerSessionId(appSessionId, appConfigRepository: appConfigRepository)
    }
    
    override func executeUseCase(requestValues: ConfirmNoSepaTransferOTPUseCaseInput) throws -> UseCaseResponse<ConfirmNoSepaTransferOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let response = try bsanManagersProvider.getBsanTransfersManager().confirmationIntNoSEPA(
            validationIntNoSepaDTO: requestValues.noSepaTransferValidation.dto,
            validationSwiftDTO: requestValues.swiftValidation?.dto,
            noSepaTransferInput: requestValues.toNoSepaTransferInput(beneficiaryAccount: requestValues.beneficiaryAccount, beneficiaryAddress: requestValues.beneficiaryAddress),
            otpValidationDTO: requestValues.otpValidation.otpValidationDTO,
            otpCode: requestValues.otpCode,
            countryCode: requestValues.countryCode,
            aliasPayee: requestValues.aliasPayee,
            isNewPayee: requestValues.isNewPayee,
            trusteerInfo: trusteerInfo
        )
        if response.isSuccess(), let result = try response.getResponseData() {
            return .ok(ConfirmNoSepaTransferOTPUseCaseOkOutput(result: result.result))
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResult(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

struct ConfirmNoSepaTransferOTPUseCaseInput: NoSEPATransferInputConvertible {
    let originAccount: Account
    let beneficiary: String
    let beneficiaryAccount: InternationalAccount
    let beneficiaryAddress: Address?
    let dateOperation: Date?
    let transferAmount: Amount
    let expensiveIndicator: NoSepaTransferExpenses
    let countryCode: String
    let concept: String
    let noSepaTransferValidation: NoSepaTransferValidation
    let swiftValidation: SwiftValidation?
    let otpValidation: OTPValidation
    let otpCode: String
    let beneficiaryEmail: String?
    let aliasPayee: String?
    let isNewPayee: Bool
}

struct ConfirmNoSepaTransferOTPUseCaseOkOutput {
    let result: String?
}
