import Foundation
import CoreDomain

public struct AccountTransactionDTO: BaseTransactionDTO {
	public var operationDate: Date?
	public var amount: AmountDTO?
	public var description: String?
	
	public var balance: AmountDTO?
	public var dgoNumber: DGONumberDTO?
	public var annotationDate: Date?
	public var valueDate: Date?
	public var transactionNumber: String?
	public var transactionType: String?
	public var productSubtypeCode: String?
	public var transactionDay: String?
    public var newContract: ContractDTO?
    public var pdfIndicator: String?

    public var status: String?
    public var recipientData: String?
    public var recipientAccountNumber: String?
    public var senderData: String?
    public var senderAccountNumber: String?
    public var transactionStatus: String?
    public var receiptId: String?
    public init() {}
}

extension AccountTransactionDTO: TransferRepresentable {
    
    public var ibanRepresentable: IBANRepresentable? {
        guard let iban = self.senderAccountNumber else {
            return nil
        }
        return IBANDTO(ibanString: iban)
    }
    
    public var name: String? {
        self.senderData ?? stripBeneficiary()
    }

    public var transferConcept: String? {
        self.description
    }

    public var typeOfTransfer: TransferRepresentableType? {
        self.getTransferType(self.amount?.value ?? 0.0)
    }

    public var scheduleType: TransferRepresentableScheduleType? {
        .normal
    }

    public var amountRepresentable: AmountRepresentable? {
        self.amount
    }

    public var transferExecutedDate: Date? {
        self.operationDate
    }

    public var transferNumber: String? {
        self.transactionNumber
    }

    public var contractRepresentable: ContractRepresentable? {
        self.newContract
    }
}

extension AccountTransactionDTO: AccountPendingTransactionRepresentable {
    public var entryStatus: TransactionStatusRepresentableType? {
        guard let transactionStatus = self.transactionStatus else {
            return nil
        }
        return TransactionStatusRepresentableType(rawValue: transactionStatus)
    }
    
    public var transactionID: String? {
        transactionNumber
    }
    
    public var transferType: String? {
        transactionType
    }
}

private extension AccountTransactionDTO {
    func getTransferType(_ amount: Decimal) -> TransferRepresentableType? {
        return amount < 0 ? .emitted : .received
    }
    
    func stripBeneficiary() -> String? {
        guard let desc = description?.replace("TRANSFERENCIA DE ", "") else { return nil }
        guard let name = desc.split(separator: ",").first, !name.isEmpty else { return description }
        return String(name).trim()
    }
}
