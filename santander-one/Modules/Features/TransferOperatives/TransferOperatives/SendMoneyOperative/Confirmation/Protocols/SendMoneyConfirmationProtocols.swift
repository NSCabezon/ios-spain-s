//
//  SendMoneyConfirmationProtocols.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 16/11/21.
//

import CoreFoundationLib
import CoreDomain

public protocol SendMoneyConfirmationStepUseCaseProtocol: UseCase<SendMoneyConfirmationStepUseCaseInput, SendMoneyTransferSummaryState, StringErrorOutput> { }

public struct SendMoneyConfirmationStepUseCaseInput {
    public let originAccount: AccountRepresentable
    public let destinationIBAN: IBANRepresentable
    public let name: String?
    public let alias: String?
    public let amount: AmountRepresentable
    public let concept: String?
    public let type: OnePayTransferType
    public let subType: SendMoneyTransferTypeProtocol?
    public let scheduledTransfer: ValidateScheduledTransferRepresentable?
    public let transactionType: String?
    public let payeeSelected: PayeeRepresentable?
    public let time: SendMoneyDateTypeFilledViewModel?
}
