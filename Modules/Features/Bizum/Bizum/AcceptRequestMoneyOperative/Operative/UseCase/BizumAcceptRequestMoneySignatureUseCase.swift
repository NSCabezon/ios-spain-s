import Foundation
import CoreFoundationLib
import SANLibraryV3

class BizumAcceptRequestMoneySignatureUseCase: UseCase<BizumAcceptRequestMoneySignatureUseCaseInput, BizumAcceptRequestMoneySignatureUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumAcceptRequestMoneySignatureUseCaseInput) throws -> UseCaseResponse<BizumAcceptRequestMoneySignatureUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let amount = requestValues.amount.value?.getStringValue() else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let parameters = BizumValidateMoneyTransferOTPInputParams(
            checkPayment: requestValues.checkPayment.dto,
            signatureWithTokenDTO: requestValues.signatureWithToken.signatureWithTokenDTO,
            amount: amount,
            numberOfRecipients: requestValues.numberOfRecipients,
            operation: "C2CASD",
            account: requestValues.account?.dto,
            footPrint: "",
            deviceMagicPhrase: ""
        )
        let response = try self.provider.getBSANBizumManager().validateMoneyTransferOTP(parameters)
        if response.isSuccess(), let data = try response.getResponseData() {
            let output = BizumValidateMoneyTransferOTPEntity(data)
            return UseCaseResponse.ok(BizumAcceptRequestMoneySignatureUseCaseOkOutput(validateMoneyTransferOTPEntity: output))
        } else {
            let signatureType = try processSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct BizumAcceptRequestMoneySignatureUseCaseInput {
    let checkPayment: BizumCheckPaymentEntity
    let signatureWithToken: SignatureWithTokenEntity
    let amount: AmountEntity
    let numberOfRecipients: Int
    let account: AccountEntity?
}

struct BizumAcceptRequestMoneySignatureUseCaseOkOutput {
    let validateMoneyTransferOTPEntity: BizumValidateMoneyTransferOTPEntity
}
