//
//  TimeLineTransfersEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 20/03/2020.
//

import Foundation

public struct TimeLineTransfersEntity: TimeLineEntityConformable {
    public var amount: Decimal
    public var merchant: (code: String, name: String)
    public var fullDate: Date
    public var month: String
    public var ibanEntity: IBANEntity?
    public let transferType: KindOfTransfer
    
    public init(amount: Decimal, fullDate: Date, month: String, merchant: (code: String, name: String), ibanEntity: IBANEntity?, transferType: KindOfTransfer) {
        self.amount = amount
        self.fullDate = fullDate
        self.month = month
        self.merchant = merchant
        self.ibanEntity = ibanEntity
        self.transferType = transferType
    }
}

extension TimeLineTransfersEntity: TransferEntityProtocol {
    public var executedDate: Date? {
        return fullDate
    }
    
    public var beneficiary: String? {
        return merchant.name
    }
    
    public var concept: String? {
        return ""
    }
    
    public var amountEntity: AmountEntity {
        return AmountEntity(value: amount)
    }
    
    public var instantPaymentId: String? {
        return nil
    }
}
