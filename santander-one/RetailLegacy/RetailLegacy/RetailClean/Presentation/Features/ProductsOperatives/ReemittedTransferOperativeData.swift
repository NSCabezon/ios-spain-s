//

import Foundation

class ReemittedTransferOperativeData: OnePayTransferOperativeData {
    
    let transferDetail: EmittedTransferDetail
    let transfer: TransferEmitted
    
    init(transferDetail: EmittedTransferDetail, transfer: TransferEmitted, account: Account?) {
        self.transferDetail = transferDetail
        self.transfer = transfer
        super.init(account: account)
        self.isModifyAvailableOnePay = false
        self.isModifySelectorAccountOnePay = !self.isProductSelectedWhenCreated
    }
}
