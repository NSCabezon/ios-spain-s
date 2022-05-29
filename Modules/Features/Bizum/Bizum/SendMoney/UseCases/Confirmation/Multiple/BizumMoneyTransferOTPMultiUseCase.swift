import Foundation
import CoreFoundationLib
import SANLibraryV3
import Operative

class BizumMoneyTransferOTPMultiUseCase: UseCase<BizumMoneyTransferOTPMultiInputUseCase, Void, GenericErrorOTPErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: BizumMoneyTransferOTPMultiInputUseCase) throws -> UseCaseResponse<Void, GenericErrorOTPErrorOutput> {
        let input = BizumMoneyTransferOTPMultiInputParams(
            checkPayment: requestValues.checkPayment.dto,
            otpValidationDTO: requestValues.otpValidation.dto,
            document: requestValues.document.dto,
            otpCode: requestValues.otpCode,
            validateMoneyTransferMultiDTO: requestValues.validateMoneyTransferMulti.dto,
            dateTime: requestValues.dateTime,
            concept: requestValues.concept,
            amount: requestValues.amount.getFormattedServiceValue(),
            account: requestValues.account?.dto,
            tokenPush: requestValues.tokenPush
        )
        let response = try self.provider.getBSANBizumManager()
            .moneyTransferOTPMulti(input)
        if response.isSuccess(), try response.getResponseData() != nil {
            return UseCaseResponse.ok()
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResultUsingServerMessage(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

extension BizumMoneyTransferOTPMultiUseCase: OTPUseCaseProtocol {}

struct BizumMoneyTransferOTPMultiInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let otpValidation: OTPValidationEntity
    let document: BizumDocumentEntity
    let otpCode: String
    let validateMoneyTransferMulti: BizumValidateMoneyTransferMultiEntity
    let dateTime: Date
    let concept: String
    let amount: AmountEntity
    let account: AccountEntity?
    let tokenPush: String?
}
