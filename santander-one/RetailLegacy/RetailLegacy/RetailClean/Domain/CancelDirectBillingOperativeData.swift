import Foundation

class CancelDirectBillingOperativeData {
    let bill: Bill
    let billDetail: BillDetail
    var cancelDirectBilling: CancelDirectBilling?
    var account: Account?
    
    init(bill: Bill, billDetail: BillDetail) {
        self.bill = bill
        self.billDetail = billDetail
    }
    
    func update(account: Account) {
        self.account = account
    }
}

extension CancelDirectBillingOperativeData: OperativeParameter {}
