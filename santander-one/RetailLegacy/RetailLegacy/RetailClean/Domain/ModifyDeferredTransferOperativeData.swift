import Foundation
import SANLegacyLibrary

class ModifyDeferredTransferOperativeData: OperativeParameter {
    let transferScheduled: TransferScheduled
    let scheduledTransferDetail: ScheduledTransferDetail
    let account: Account
    var country: SepaCountryInfo?
    var currency: SepaCurrencyInfo?
    var modifiedData: ModifiedDeferredTransfer?
    var modifyDeferredTransfer: ModifyDeferredTransfer?
    var modifyScheduledTransferInput: ModifyScheduledTransferInput?
    
    init(transferScheduled: TransferScheduled, scheduledTransferDetail: ScheduledTransferDetail, account: Account) {
        self.transferScheduled = transferScheduled
        self.scheduledTransferDetail = scheduledTransferDetail
        self.account = account
    }
}
