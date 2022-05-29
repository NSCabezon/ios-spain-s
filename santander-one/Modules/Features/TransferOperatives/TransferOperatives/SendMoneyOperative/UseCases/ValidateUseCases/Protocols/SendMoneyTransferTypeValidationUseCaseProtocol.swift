//
//  SendMoneyTransferTypeValidationUseCaseProtocol.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 6/12/21.
//

import CoreFoundationLib
import CoreDomain

public protocol TransferTypeValidationUseCaseProtocol: UseCase<TransferTypeValidationUseCaseInput,
                                                               TransferTypeValidationUseCaseOkOutput,
                                                               StringErrorOutput> {}

public struct TransferTypeValidationUseCaseInput {
    public let type: OnePayTransferType
    public let subType: SendMoneyTransferTypeProtocol?
    public let originAccount: AccountRepresentable
    public let destinationIBAN: IBANRepresentable
    public let amount: AmountRepresentable
    public let concept: String?
    public let name: String?
    public let alias: String?
    public let saveFavorites: Bool
    public let beneficiaryMail: String?
    public let maxAmount: AmountRepresentable?
    public let checkEntityAdhered: Bool
    public let isUrgent: Bool
    
    public init(type: OnePayTransferType,
                subType: SendMoneyTransferTypeProtocol?,
                originAccount: AccountRepresentable,
                destinationIBAN: IBANRepresentable,
                amount: AmountRepresentable,
                concept: String?,
                name: String?,
                alias: String?,
                saveFavorites: Bool,
                beneficiaryMail: String?,
                maxAmount: AmountRepresentable?,
                checkEntityAdhered: Bool,
                isUrgent: Bool) {
        self.type = type
        self.subType = subType
        self.originAccount = originAccount
        self.destinationIBAN = destinationIBAN
        self.amount = amount
        self.concept = concept
        self.name = name
        self.alias = alias
        self.saveFavorites = saveFavorites
        self.beneficiaryMail = beneficiaryMail
        self.maxAmount = maxAmount
        self.checkEntityAdhered = checkEntityAdhered
        self.isUrgent = isUrgent
    }
}

public struct TransferTypeValidationUseCaseOkOutput {
    public let transferNational: TransferNationalRepresentable?
}

public final class TransferTypeValidationUseCaseErrorOutput: StringErrorOutput {
    let error: TransferTypeValidationError
    
    public init(_ error: TransferTypeValidationError) {
        self.error = error
        super.init("")
    }
}

public enum TransferTypeValidationError {
    case serviceError(errorDesc: String?)
    case urgentNationalTransfers5304(text: String?)
    case maxAmount
    case nonAttachedEntity
}
