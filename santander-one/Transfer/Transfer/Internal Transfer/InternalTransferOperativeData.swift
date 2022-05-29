import CoreFoundationLib

final class InternalTransferOperativeData {
    var accountVisibles: [AccountEntity] = []
    var accountNotVisibles: [AccountEntity] = []
    var selectedAccount: AccountEntity?
    var destinationAccount: AccountEntity?
    var amount: AmountEntity?
    var concept: String?
    var time: TransferTime?
    var internalTransfer: InternalTransferEntity?
    var scheduledTransfer: ValidateScheduledTransferEntity?
    var faqs: [FaqsEntity]?
    
    init(selectedAccount: AccountEntity?) {
        self.selectedAccount = selectedAccount
    }
}
