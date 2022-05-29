//
//  ValidateOTPGenericSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 29/07/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class ValidateOTPGenericSendMoneyUseCase: UseCase<ConfirmNationalGenericSendMoneyInput, ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput> {

    private let dependenciesResolver: DependenciesResolver

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmNationalGenericSendMoneyInput) throws -> UseCaseResponse<ConfirmNationalGenericSendMoneyOkOutput, GenericErrorSignatureErrorOutput> {
        let manager: TransfersRepository = dependenciesResolver.resolve()
        let input = NationalTransferInput(beneficiary: requestValues.beneficiary,
                                          isSpanishResident: true,
                                          ibanRepresentable: requestValues.iban,
                                          saveAsUsual: requestValues.saveAsUsual,
                                          saveAsUsualAlias: requestValues.saveAsUsualAlias,
                                          beneficiaryMail: requestValues.beneficiaryMail,
                                          amountRepresentable: requestValues.amount,
                                          concept: requestValues.concept)
        let signature = requestValues.signature
        let response = try manager.validateGenericTransferOTP(originAccount: requestValues.originAccount,
                                                              nationalTransferInput: input,
                                                              signature: signature)
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


public struct ConfirmNationalGenericSendMoneyInput {
    let signature: SignatureRepresentable
    let type: OnePayTransferType
    let originAccount: AccountRepresentable
    let amount: AmountRepresentable
    let beneficiary: String
    let iban: IBANRepresentable
    let saveAsUsual: Bool
    let concept: String?
    let saveAsUsualAlias: String?
    let beneficiaryMail: String?
    let time: SendMoneyDateTypeViewModel
    let dataToken: String?
}

public struct ConfirmNationalGenericSendMoneyOkOutput {
    let otp: OTPValidationRepresentable?
}


