//
//  ValidateScheduledSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 28/07/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative

public protocol ValidateScheduledSendMoneyUseCaseProtocol: UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput> {}

class ValidateScheduledSendMoneyUseCase: UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput>, ValidateSendMoneyProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateSendMoneyUseCaseInput) throws -> UseCaseResponse<ValidateSendMoneyUseCaseOkOutput, StringErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail, !beneficiaryMail.isEmpty, !beneficiaryMail.isValidEmail() {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        let transferType: String? = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType?.serviceString ?? "")
        let response = try validateScheduleType(requestValues: requestValues, iban: requestValues.destinationIBAN, subType: transferType)
        switch response {
        case .success(let validate):
            guard let scaRepresentable = validate.scaRepresentable else {
                return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
            }
            return UseCaseResponse.ok(ValidateSendMoneyUseCaseOkOutput(scheduledTransfer: validate,
                                                                       beneficiaryMail: requestValues.beneficiaryMail,
                                                                       sca: SCAEntity(scaRepresentable)))

        case .failure(let error) :
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
}

extension ValidateScheduledSendMoneyUseCase: ValidateScheduledSendMoneyUseCaseProtocol {}
