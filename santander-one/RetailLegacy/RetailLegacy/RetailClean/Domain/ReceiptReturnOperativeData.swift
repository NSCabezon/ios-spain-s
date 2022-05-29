class ReceiptReturnOperativeData {
    let bill: Bill
    var detailBill: BillDetail
    var account: Account?
    
    init(bill: Bill, detailBill: BillDetail) {
        self.bill = bill
        self.detailBill = detailBill
    }
    
    func update(account: Account, detailBill: BillDetail) {
        self.account = account
        self.detailBill = detailBill
    }
}

extension ReceiptReturnOperativeData: OperativeParameter {}
