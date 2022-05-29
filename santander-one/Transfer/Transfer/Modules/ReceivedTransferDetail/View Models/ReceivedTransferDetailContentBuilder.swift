import CoreFoundationLib

struct ReceivedTransferDetailContentBuilder {
    let transfer: TransferReceivedEntity
    private var content: [ReceivedTransferDetailSectionViewModel] = []
    
    init(transfer: TransferReceivedEntity) {
        self.transfer = transfer
    }
    
    mutating func addType() -> Self {
        content.append(
            ReceivedTransferDetailSectionViewModel(
                titleKey: "deliveryDetails_label_type",
                value: localized("deliveryDetails_label_receiveTransfer"),
                valueAccessibilityIdentifier: "deliveryDetails_label_receiveTransfer"
            )
        )
        return self
    }
    
    mutating func addAccount() -> Self {
        let account: String = {
            let aliasAccountBeneficiary = transfer.aliasAccountBeneficiary ?? ""
            let amount = transfer.balanceEntity.getStringValue()
            return aliasAccountBeneficiary + " (" + amount + ")"
        }()
        content.append(
            ReceivedTransferDetailSectionViewModel(
                titleKey: "deliveryDetails_label_destinationAccounts",
                value: account,
                valueAccessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.destinationAccount
            )
        )
        return self
    }
    
    mutating func addOperationDate() -> Self {
        guard let date = transfer.operationDate else { return self }
        let formatter = DateFormatter()
        formatter.dateFormat = TimeFormat.dd_MMM_yyyy.rawValue
        content.append(
            ReceivedTransferDetailSectionViewModel(
                titleKey: "deliveryDetails_label_operationDate",
                value: formatter.string(from: date),
                valueAccessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.operationDate
            )
        )
        return self
    }
    
    mutating func addValueDate() -> Self {
        guard let date = transfer.valueDate else { return self }
        let formatter = DateFormatter()
        formatter.dateFormat = TimeFormat.dd_MMM_yyyy.rawValue
        content.append(
            ReceivedTransferDetailSectionViewModel(
                titleKey: "deliveryDetails_label_valueDate",
                value: formatter.string(from: date),
                valueAccessibilityIdentifier: TransferReceivedDetailAccessibilityIdentifier.valueDate
            )
        )
        return self
    }
    
    func build() -> [ReceivedTransferDetailSectionViewModel] {
        return content
    }
}
