//
//  ConfirmGenericSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 29/07/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative
import CoreDomain

public protocol ConfirmGenericSendMoneyUseCaseProtocol: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> { }

class ConfirmGenericSendMoneyUseCase: UseCase<ConfirmOtpSendMoneyUseCaseInput, ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput>, OTPUseCaseProtocol, ValidateSendMoneyProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ConfirmOtpSendMoneyUseCaseInput) throws -> UseCaseResponse<ConfirmOtpSendMoneyUseCaseOkOutput, GenericErrorOTPErrorOutput> {
        let manager: TransfersRepository = dependenciesResolver.resolve()
        let transferType = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType.serviceString)
        let input = SendMoneyGenericTransferInput(ibanRepresentable: requestValues.destinationIBAN,
                                                  amountRepresentable: requestValues.amount,
                                                  concept: requestValues.concept,
                                                  beneficiary: requestValues.name,
                                                  saveAsUsual: requestValues.saveFavorites,
                                                  saveAsUsualAlias: requestValues.alias,
                                                  transferType: transferType,
                                                  beneficiaryMail: requestValues.beneficiaryMail)
        let response = try manager.confirmGenericTransfer(
            originAccount: requestValues.originAccount,
            nationalTransferInput: input,
            otpValidation: requestValues.otpValidation,
            otpCode: requestValues.code)
        switch response {
        case .success(let data):
            return UseCaseResponse.ok(ConfirmOtpSendMoneyUseCaseOkOutput(transferConfirmAccount: TransferConfirmAccountDTO(transferConfirmAccountRepresentable: data)))
        case .failure(let error):
            let nsError = error as NSError 
            return UseCaseResponse.error(GenericErrorOTPErrorOutput(nsError.localizedDescription, self.getOTPResult(errorMessage: nsError.localizedDescription), nsError.errorCode))
        }
    }
}

extension ConfirmGenericSendMoneyUseCase: ConfirmGenericSendMoneyUseCaseProtocol { }

public struct ConfirmOtpSendMoneyUseCaseInput: ScheduledTransferRepresentableConvertible {
    public let otpValidation: OTPValidationRepresentable?
    public let code: String
    public let type: OnePayTransferType
    public let subType: SendMoneyTransferTypeProtocol
    public let originAccount: AccountRepresentable
    public let destinationIBAN: IBANRepresentable
    public let name: String?
    public let alias: String?
    public let isSpanishResident: Bool
    public let saveFavorites: Bool
    public let beneficiaryMail: String?
    public let amount: AmountRepresentable
    public let concept: String?
    public let time: SendMoneyDateTypeFilledViewModel
    public let scheduledTransfer: ValidateScheduledTransferRepresentable?
}

public struct ConfirmOtpSendMoneyUseCaseOkOutput {
    let transferConfirmAccount: TransferConfirmAccountRepresentable?
    
    public init(transferConfirmAccount: TransferConfirmAccountRepresentable?) {
        self.transferConfirmAccount = transferConfirmAccount
    }
}
