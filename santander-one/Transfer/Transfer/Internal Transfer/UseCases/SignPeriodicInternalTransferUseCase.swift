import Foundation
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class SignPeriodicInternalTransferUseCase: UseCase<SignScheduledInternalTransferUseCaseInput, SignScheduledInternalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SignScheduledInternalTransferUseCaseInput) throws -> UseCaseResponse<SignScheduledInternalTransferUseCaseOkOutput, GenericErrorSignatureErrorOutput> {
        guard let signature = requestValues.signature as? SignatureDTO else {
            return .error(GenericErrorSignatureErrorOutput(nil, .otherError, nil))
        }
        let response = try provider.getBsanTransfersManager().validateScheduledTransferOTP(
            signatureDTO: signature,
            dataToken: requestValues.scheduledTransfer.dataMagicPhrase ?? ""
        )
        let signatureType = try processSignatureResult(response)
        if var otpValidationOTP = try? response.getResponseData() {
            if case .otpUserExcepted = signatureType {
                otpValidationOTP.otpExcepted = true
                let otp = OTPValidationEntity(otpValidationOTP)
                return .ok(SignScheduledInternalTransferUseCaseOkOutput(otp: otp))
            } else {
                let otp = OTPValidationEntity(otpValidationOTP)
                return .ok(SignScheduledInternalTransferUseCaseOkOutput(otp: otp))
            }
        } else {
            let errorDescription = try response.getErrorMessage()
            let errorCode = try response.getErrorCode()
            return .error(GenericErrorSignatureErrorOutput(errorDescription, signatureType, errorCode))
        }
    }
}

struct SignScheduledInternalTransferUseCaseInput {
    let originAccount: AccountEntity
    let destinationAccount: AccountEntity
    let amount: AmountEntity
    let concept: String
    let signature: SignatureRepresentable
    let transferTime: TransferTime
    let scheduledTransfer: ValidateScheduledTransferEntity
}

struct SignScheduledInternalTransferUseCaseOkOutput {
    let otp: OTPValidationEntity?
}
