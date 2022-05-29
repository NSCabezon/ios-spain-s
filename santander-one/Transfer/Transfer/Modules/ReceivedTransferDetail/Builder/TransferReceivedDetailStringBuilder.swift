import Foundation
import CoreFoundationLib

struct TransferReceivedDetailStringBuilder {
    private let transfer: TransferReceivedEntity
    
    private var sharedString: String = ""
    
    init(transfer: TransferReceivedEntity) {
        self.transfer = transfer
    }
    
    mutating func addTransferType() {
        sharedString.append(localized("deliveryDetails_label_receiveTransfer"))
        addLineBreak()
    }
    
    mutating func addAmount() {
        let value = String(
            format: "%@ %@",
            localized("summary_item_amount"),
            transfer.amountEntity.getStringValue()
        )
        self.sharedString.append(value)
        self.addLineBreak()
    }
    
    mutating func addDescription() {
        guard let description = transfer.description else { return }
        let value = String(
            format: "%@ %@",
            localized("summary_item_concept"),
            description
        )
        self.sharedString.append(value)
        self.addLineBreak()
    }
    
    mutating func addAliasAccountBeneficiary() {
        guard let aliasAccountBeneficiary = transfer.aliasAccountBeneficiary else { return }
        let value = String(
            format: "%@ %@",
            localized("summary_item_destinationAccounts"),
            aliasAccountBeneficiary
        )
        self.sharedString.append(value)
        self.addLineBreak()
    }
    
    mutating func addAnnotationDate() {
        guard let annotationDate = transfer.annotationDate else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let value = String(
            format: "%@ %@",
            localized("summary_item_transactionDate"),
            formatter.string(from: annotationDate)
        )
        self.sharedString.append(value)
        self.addLineBreak()
    }
    
    private mutating func addLineBreak() {
        sharedString.append("\n")
    }
    
    func build() -> String {
        return sharedString
    }
}
