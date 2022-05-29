import Foundation
import CoreFoundationLib
import SANLibraryV3

final class SignRefundMoneyUseCase: UseCase<SignRefundMoneyUseCaseInput, SignRefundMoneyUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let managersProvider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.managersProvider = self.dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: SignRefundMoneyUseCaseInput) throws -> UseCaseResponse<SignRefundMoneyUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        let bizumManager = self.managersProvider.getBSANBizumManager()
        let response = try bizumManager.signRefundMoney(
            with: BizumSignRefundMoneyInputParams(
                iban: requestValues.iban.dto,
                signatureWithTokenDTO: requestValues.signature.signatureWithTokenDTO,
                amount: requestValues.amount.dto
            )
        )
        guard response.isSuccess(), let responseData = try response.getResponseData() else {
            let signatureType = try processSignatureResult(response)
            let errorDescription = try response.getErrorMessage() ?? ""
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
        return .ok(SignRefundMoneyUseCaseOkOutput(otpValidation: OTPValidationEntity(responseData.otp)))
    }
}

struct SignRefundMoneyUseCaseInput {
    let iban: IBANEntity
    let signature: SignatureWithTokenEntity
    let amount: AmountEntity
}

struct SignRefundMoneyUseCaseOkOutput {
    let otpValidation: OTPValidationEntity
}
