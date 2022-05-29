//
//  TransferReceivedEntity.swift
//  Models
//
//  Created by alvola on 18/05/2020.
//

import SANLegacyLibrary

public struct TransferReceivedEntity {
    private let dto: AccountTransactionDTO
    private let accountDTO: AccountDTO
    public var instantPaymentId: String?
    
    public init(_ dto: AccountTransactionDTO, accountDTO: AccountDTO) {
        self.dto = dto
        self.accountDTO = accountDTO
    }
    
    public var beneficiary: String? {
        return stripBeneficiary()
    }
    
    public var aliasAccountBeneficiary: String? {
        return self.accountDTO.alias?.camelCasedString
    }
    
    public var operationDate: Date? {
        return dto.operationDate
    }
    
    public var amountEntity: AmountEntity {
        guard let amount = dto.amount else {
            return AmountEntity(value: 0)
        }
        return AmountEntity(amount)
    }
    
    public var description: String? {
        return dto.description
    }

    public var balanceEntity: AmountEntity {
        guard let amountDTO = self.accountDTO.currentBalance else {
            return AmountEntity(value: 0)
        }
        return AmountEntity(amountDTO)
    }
    
    public var annotationDate: Date? {
        return dto.annotationDate
    }
    
    public var valueDate: Date? {
        return dto.valueDate
    }
    
    public var transactionNumber: String? {
        return dto.transactionNumber
    }
    
    public var transactionType: String? {
        return dto.transactionType
    }
    
    public var productSubtypeCode: String? {
        return dto.productSubtypeCode
    }
    
    public var pdfIndicator: String? {
        return dto.pdfIndicator
    }
}

extension TransferReceivedEntity: Equatable {
    public static func == (lhs: TransferReceivedEntity, rhs: TransferReceivedEntity) -> Bool {
        return lhs.accountDTO == rhs.accountDTO && lhs.operationDate == rhs.operationDate && lhs.transactionNumber == rhs.transactionNumber
    }
}

extension TransferReceivedEntity: TransferEntityProtocol {
    public var executedDate: Date? {
        return self.operationDate
    }
    
    public var concept: String? {
        return self.description
    }
    
    public var transferType: KindOfTransfer {
        return .received
    }
}

private extension TransferReceivedEntity {
    func stripBeneficiary() -> String? {
        guard let desc = dto.description?.replace("TRANSFERENCIA DE ", "") else { return dto.description }
        guard let name = desc.split(separator: ",").first, !name.isEmpty else { return dto.description }
        return String(name).trim()
    }
}
