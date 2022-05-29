import Foundation

class ModifyPeriodicTransferOperativeData: OperativeParameter {
    let transferScheduled: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
    let account: Account
    var country: SepaCountryInfo?
    var currency: SepaCurrencyInfo?
    var modifiedData: ModifiedPeriodicTransfer?
    var modifyPeriodicTransfer: ModifyPeriodicTransfer?
    
    init(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account) {
        self.transferScheduled = transferScheduled
        self.scheduledTransferDetail = scheduledTransferDetail
        self.account = account
    }
}
