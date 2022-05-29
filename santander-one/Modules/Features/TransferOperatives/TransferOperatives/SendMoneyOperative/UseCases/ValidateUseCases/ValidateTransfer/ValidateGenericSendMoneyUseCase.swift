//
//  ValidateGenericSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 03/08/2021.
//

import SANLegacyLibrary
import CoreFoundationLib
import Operative
import CoreDomain

public protocol ValidateGenericSendMoneyUseCaseProtocol: UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput> {}

class ValidateGenericSendMoneyUseCase: UseCase<ValidateSendMoneyUseCaseInput, ValidateSendMoneyUseCaseOkOutput, StringErrorOutput>, ValidateSendMoneyProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: ValidateSendMoneyUseCaseInput) throws -> UseCaseResponse<ValidateSendMoneyUseCaseOkOutput, StringErrorOutput> {
        if let beneficiaryMail = requestValues.beneficiaryMail, !beneficiaryMail.isEmpty, !beneficiaryMail.isValidEmail() {
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.invalidEmail))
        }
        if !requestValues.shouldValidateTransfer {
            return UseCaseResponse.ok(ValidateSendMoneyUseCaseOkOutput(beneficiaryMail: nil, sca: nil))
        }
        let transferType = self.dependenciesResolver.resolve(forOptionalType: SendMoneyModifierProtocol.self)?.transferTypeFor(onePayType: requestValues.type, subtype: requestValues.subType?.serviceString ?? "")
        let genericTransferDTO = SendMoneyGenericTransferInput(
            ibanRepresentable: requestValues.destinationIBAN,
            amountRepresentable: requestValues.amount,
            concept: requestValues.concept,
            beneficiary: requestValues.name,
            saveAsUsual: requestValues.saveFavorites,
            saveAsUsualAlias: requestValues.alias,
            transferType: transferType,
            beneficiaryMail: requestValues.beneficiaryMail
        )
        let response = try self.validateSepaTransfer(originAccount: requestValues.originAccount, genericTransferDTO: genericTransferDTO, isConfirmationStep: requestValues.isConfirmationStep)
        switch response {
        case .success(let validate):
            guard let transferNational = validate.transferNationalRepresentable,
                  let scaRepresentable = transferNational.scaRepresentable else {
                return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: nil)))
            }
            
            return UseCaseResponse.ok(ValidateSendMoneyUseCaseOkOutput(
                                        transferNational: transferNational,
                                        beneficiaryMail: requestValues.beneficiaryMail,
                                        sca: SCAEntity(scaRepresentable)))
        case .failure(let error):
            return UseCaseResponse.error(ValidateTransferUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
}

extension ValidateGenericSendMoneyUseCase: ValidateGenericSendMoneyUseCaseProtocol {}

public struct ValidateSendMoneyUseCaseInput: ScheduledTransferRepresentableConvertible {
    public let originAccount: AccountRepresentable
    public let destinationIBAN: IBANRepresentable
    public let name: String?
    public let alias: String?
    public let saveFavorites: Bool
    public let beneficiaryMail: String?
    public let amount: AmountRepresentable
    public let concept: String?
    public let type: OnePayTransferType
    public let subType: SendMoneyTransferTypeProtocol?
    public let time: SendMoneyDateTypeFilledViewModel
    public let scheduledTransfer: ValidateScheduledTransferRepresentable?
    public let transactionType: String?
    public let payeeSelected: PayeeRepresentable?
    public var isConfirmationStep: Bool = false
    public var shouldValidateTransfer: Bool = true
}

public struct ValidateSendMoneyUseCaseOkOutput {
    let transferNational: TransferNationalRepresentable?
    let scheduledTransfer: ValidateScheduledTransferRepresentable?
    let beneficiaryMail: String?
    let scaEntity: SCAEntity?
    
    public init(transferNational: TransferNationalRepresentable? = nil, scheduledTransfer: ValidateScheduledTransferRepresentable? = nil, beneficiaryMail: String?, sca: SCAEntity?) {
        self.transferNational = transferNational
        self.scheduledTransfer = scheduledTransfer
        self.beneficiaryMail = beneficiaryMail
        self.scaEntity = sca
    }
}
