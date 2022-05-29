//
//  InternalTransferEntity.swift
//  Transfer
//
//  Created by Jose Carlos Estela Anguita on 08/01/2020.
//

import Foundation
import SANLegacyLibrary

public final class InternalTransferEntity {
    
    public let issueDate: Date
    public let transferAmount: AmountEntity
    public let bankChargeAmount: AmountEntity
    public let expensesAmount: AmountEntity
    public let netAmount: AmountEntity
    
    public init?(transferAccountDTO: TransferAccountDTO) {
        guard
            let issueDate = transferAccountDTO.issueDate,
            let transferAmountDTO = transferAccountDTO.transferAmount,
            let bankChargeAmountDTO = transferAccountDTO.bankChargeAmount,
            let expensesAmountDTO = transferAccountDTO.expensesAmount,
            let netAmountDTO = transferAccountDTO.netAmount
        else {
            return nil
        }
        self.issueDate = issueDate
        self.transferAmount = AmountEntity(transferAmountDTO)
        self.bankChargeAmount = AmountEntity(bankChargeAmountDTO)
        self.expensesAmount = AmountEntity(expensesAmountDTO)
        self.netAmount = AmountEntity(netAmountDTO)
    }
    
    public init?(scheduledTransfer: ValidateScheduledTransferEntity,
                 issueDate: Date,
                 transferAmount: AmountEntity) {
        let expensesAmount = AmountEntity(value: 0)
        let bankChargeAmount = scheduledTransfer.bankChargeAmount ?? AmountEntity(value: 0)
        self.issueDate = issueDate
        self.transferAmount = transferAmount
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.netAmount = transferAmount
    }
    
    public init?(amount: AmountEntity,
                 issueDate: Date) {
        let expensesAmount = AmountEntity(value: 0)
        let bankChargeAmount = AmountEntity(value: 0)
        self.issueDate = issueDate
        self.transferAmount = amount
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.netAmount = amount
    }
}
