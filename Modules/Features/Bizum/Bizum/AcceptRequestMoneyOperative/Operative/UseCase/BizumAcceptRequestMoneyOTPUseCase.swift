import Foundation
import CoreFoundationLib
import SANLibraryV3
import Operative

class BizumAcceptRequestMoneyOTPUseCase: UseCase<BizumAcceptRequestMoneyOTPUseCaseInput, BizumAcceptRequestMoneyOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumAcceptRequestMoneyOTPUseCaseInput) throws -> UseCaseResponse<BizumAcceptRequestMoneyOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let input = self.generateInputParams(requestValues: requestValues)
        let response = try self.provider.getBSANBizumManager().acceptRequestMoneyTransferOTP(input)
        if response.isSuccess(), let data = try response.getResponseData() {
            return UseCaseResponse.ok(BizumAcceptRequestMoneyOTPUseCaseOkOutput(moneyTransferOTP: BizumMoneyTransferOTPEntity(data)))
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResultUsingServerMessage(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

private extension BizumAcceptRequestMoneyOTPUseCase {
    func generateInputParams(requestValues: BizumAcceptRequestMoneyOTPUseCaseInput) -> BizumAcceptRequestMoneyTransferOTPInputParams {
        return BizumAcceptRequestMoneyTransferOTPInputParams(
            checkPayment: requestValues.checkPayment.dto,
            otpValidationDTO: requestValues.otpValidation.dto,
            document: requestValues.document.dto,
            otpCode: requestValues.otpCode,
            operationId: requestValues.operationId,
            dateTime: requestValues.dateTime,
            concept: requestValues.concept,
            amount: requestValues.amount.getFormattedServiceValue(),
            receiverUserId: requestValues.receiverUserId,
            magicPhrasePush: ""
        )
    }
}

extension BizumAcceptRequestMoneyOTPUseCase: OTPUseCaseProtocol {}

struct BizumAcceptRequestMoneyOTPUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let otpValidation: OTPValidationEntity
    let document: BizumDocumentEntity
    let otpCode: String
    let operationId: String
    let dateTime: Date
    let concept: String
    let amount: AmountEntity
    let receiverUserId: String
}

struct BizumAcceptRequestMoneyOTPUseCaseOkOutput {
    let moneyTransferOTP: BizumMoneyTransferOTPEntity
}
