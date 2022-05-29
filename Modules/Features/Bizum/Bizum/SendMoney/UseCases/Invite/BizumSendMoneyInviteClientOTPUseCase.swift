import Foundation
import CoreFoundationLib
import SANLibraryV3
import SANLegacyLibrary
import Operative

final class BizumSendMoneyInviteClientOTPUseCase: UseCase<BizumSendMoneyInviteClientOTPUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: BizumSendMoneyInviteClientOTPUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        let input: BizumInviteNoClientOTPInputParams = BizumInviteNoClientOTPInputParams(
            checkPayment: requestValues.checkPayment.dto,
            otpValidationDTO: requestValues.otpValidation.dto,
            otpCode: requestValues.otpCode,
            validateMoneyTransferDTO: requestValues.validateMoneyTransfer.dto,
            amount: requestValues.amount.getFormattedServiceValue()
        )
        let response = try provider.getBSANBizumManager().inviteNoClientOTP(input)
        if response.isSuccess() {
            return UseCaseResponse.ok()
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResultUsingServerMessage(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

extension BizumSendMoneyInviteClientOTPUseCase: OTPUseCaseProtocol {}

struct BizumSendMoneyInviteClientOTPUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let otpValidation: OTPValidationEntity
    let otpCode: String
    let validateMoneyTransfer: BizumValidateMoneyTransferEntity
    let amount: AmountEntity
}
