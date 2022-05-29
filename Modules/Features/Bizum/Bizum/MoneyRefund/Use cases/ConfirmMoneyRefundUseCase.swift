import Foundation
import SANLibraryV3
import SANLegacyLibrary
import CoreFoundationLib
import Operative

final class ConfirmRefundMoneyUseCase: UseCase<ConfirmRefundMoneyUseCaseInput, Void, GenericErrorOTPErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let managersProvider: SANLibraryV3.BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = self.dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: ConfirmRefundMoneyUseCaseInput) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let bizumManager = self.managersProvider.getBSANBizumManager()
        let response = try bizumManager.refundMoneyRequest(BizumRefundMoneyRequestInputParams(
            checkPayment: requestValues.checkPayment.dto,
            operationId: requestValues.operation.operationId ?? "",
            transactionId: "",
            otpValidationDTO: requestValues.otp.dto,
            otpCode: requestValues.otpCode,
            dateTime: requestValues.operation.date ?? Date(),
            concept: requestValues.operation.concept ?? "",
            amount: requestValues.amount.value?.rounded() ?? 0,
            document: requestValues.document.dto,
            receiverId: requestValues.operation.emitterId ?? ""
        ))
        guard response.isSuccess() else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try self.getOTPResultUsingServerMessage(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
        return .ok()
    }
}

extension ConfirmRefundMoneyUseCase: OTPUseCaseProtocol {}

struct ConfirmRefundMoneyUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let operation: BizumHistoricOperationEntity
    let otp: OTPValidationEntity
    let otpCode: String
    let amount: AmountEntity
    let document: BizumDocumentEntity
}
