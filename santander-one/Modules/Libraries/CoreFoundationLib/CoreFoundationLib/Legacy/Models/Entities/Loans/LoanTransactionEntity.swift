//
//  LoanTransactionEntity.swift
//  Models
//
//  Created by Jose Carlos Estela Anguita on 08/10/2019.
//
import CoreDomain
import SANLegacyLibrary

public final class LoanTransactionEntity {

    public let representable: LoanTransactionRepresentable

    // swiftlint:disable force_cast
    public var dto: LoanTransactionDTO {
        precondition((representable as? LoanTransactionDTO) != nil)
        return representable as! LoanTransactionDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: LoanTransactionRepresentable) {
        self.representable = representable
    }

    public var operationDate: Date? {
        return representable.operationDate
    }
    
    public var valueDate: Date? {
        return representable.valueDate
    }

    public var description: String {
        return representable.description?.trim() ?? ""
    }

    public var amount: AmountEntity? {
        guard let amountRepresentable = representable.amountRepresentable else {
            return nil
        }
        return AmountEntity(amountRepresentable)
    }

    public var transactionNumber: String? {
        return representable.transactionNumber
    }

    public var receiptId: String? {
        return representable.receiptId
    }
}

extension LoanTransactionEntity: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(representable.dgoNumberRepresentable?.description)
        hasher.combine(representable.transactionNumber)
        hasher.combine(representable.description)
        hasher.combine(representable.amountRepresentable?.value)
    }
}

public func == (lhs: LoanTransactionEntity, rhs: LoanTransactionEntity) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
