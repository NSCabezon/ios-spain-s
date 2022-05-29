import Foundation
import CoreFoundationLib
import SANLibraryV3
import Operative

class BizumMoneyTransferOTPUseCase: UseCase<BizumMoneyTransferOTPInputUseCase, BizumMoneyTransferOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: BizumMoneyTransferOTPInputUseCase) throws -> UseCaseResponse<BizumMoneyTransferOTPUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let input = BizumMoneyTransferOTPInputParams(
            checkPayment: requestValues.checkPayment.dto,
            otpValidationDTO: requestValues.otpValidation.dto,
            document: requestValues.document.dto,
            otpCode: requestValues.otpCode,
            validateMoneyTransferDTO: requestValues.validateMoneyTransfer.dto,
            dateTime: requestValues.dateTime,
            concept: requestValues.concept,
            amount: requestValues.amount.getFormattedServiceValue(),
            receiverUserId: requestValues.receiverUserId,
            account: requestValues.account?.dto,
            magicPhrasePush: requestValues.tokenPush
        )
        let response = try self.provider
            .getBSANBizumManager()
            .moneyTransferOTP(input)
        if response.isSuccess(), let data = try response.getResponseData() {
            return UseCaseResponse.ok(BizumMoneyTransferOTPUseCaseOkOutput(moneyTransferOTP: BizumMoneyTransferOTPEntity(data)))
        } else {
            let errorDescription = try response.getErrorMessage()
            let otpType = try getOTPResultUsingServerMessage(response)
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorOTPErrorOutput(errorDescription, otpType, errorCode))
        }
    }
}

extension BizumMoneyTransferOTPUseCase: OTPUseCaseProtocol {}

struct BizumMoneyTransferOTPInputUseCase {
    let checkPayment: BizumCheckPaymentEntity
    let otpValidation: OTPValidationEntity
    let document: BizumDocumentEntity
    let otpCode: String
    let validateMoneyTransfer: BizumValidateMoneyTransferEntity
    let dateTime: Date
    let concept: String
    let amount: AmountEntity
    let receiverUserId: String
    let account: AccountEntity?
    let tokenPush: String?
}

struct BizumMoneyTransferOTPUseCaseOkOutput {
    let moneyTransferOTP: BizumMoneyTransferOTPEntity
}
