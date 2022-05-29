//
//  ValidateOTPScheduledSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 29/07/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class ValidateOTPScheduledSendMoneyUseCase: UseCase<ConfirmNationalGenericSendMoneyInput, ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput> {

    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmNationalGenericSendMoneyInput) throws -> UseCaseResponse<ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput> {
        let manager: TransfersRepository = dependenciesResolver.resolve()
        let response: Result<OTPValidationRepresentable, Error>
        if case .day = requestValues.time {
            response = try manager.validateDeferredTransferOTP(signature: requestValues.signature, dataToken: requestValues.dataToken ?? "")
        } else {
            response = try manager.validatePeriodicTransferOTP(signature: requestValues.signature, dataToken: requestValues.dataToken ?? "")
        }
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(ConfirmNationalGenericSendMoneyOkOutput(otp: data))
        case .failure(let error):
            let error = error as NSError
            let signatureType = try manager.processSendMoneySignatureResult(error)
            return UseCaseResponse.error(GenericErrorSignatureErrorOutput(error.localizedDescription, signatureType, error.errorCode))
        }
    }
}
