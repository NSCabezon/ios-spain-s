import Foundation
import CoreDomain

public struct TransferConfirmAccountDTO: Codable {
    public var destinationAccountDescription: String?
    public var originAccountDescription: String?
    public var transferAmount: AmountDTO?
    public var bankChargeAmount: AmountDTO?
    public var expensesAmount: AmountDTO?
    public var netAmount: AmountDTO?
    public var payerName: String?
    public var reference: ReferenceDTO?
    public var issueDate: Date?

    public init() {}
    
    public init(destinationAccountDescription: String, originAccountDescription: String, transferAmount: AmountDTO?, bankChargeAmount: AmountDTO?, expensesAmount: AmountDTO?, netAmount: AmountDTO?, payerName: String?, reference: ReferenceDTO?, issueDate: Date?) {
        self.destinationAccountDescription = destinationAccountDescription
        self.originAccountDescription = originAccountDescription
        self.transferAmount = transferAmount
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.netAmount = netAmount
        self.payerName = payerName
        self.reference = reference
        self.issueDate = issueDate
    }
    
    public init(transferConfirmAccountRepresentable: TransferConfirmAccountRepresentable) {
        self.destinationAccountDescription = transferConfirmAccountRepresentable.destinationAccountDescription
        self.originAccountDescription = transferConfirmAccountRepresentable.originAccountDescription
        self.payerName = transferConfirmAccountRepresentable.payerName
        self.issueDate = transferConfirmAccountRepresentable.issueDate
        var reference = ReferenceDTO()
        reference.reference = transferConfirmAccountRepresentable.referenceRepresentable?.reference
        self.reference = reference
    }
}

extension TransferConfirmAccountDTO: TransferConfirmAccountRepresentable {
    public var referenceRepresentable: ReferenceRepresentable? {
        self.reference
    }
}
