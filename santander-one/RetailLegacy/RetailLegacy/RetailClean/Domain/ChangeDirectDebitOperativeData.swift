class ChangeDirectDebitOperativeData {
    let bill: Bill
    let billDetail: BillDetail
    var accounts: [Account] = []
    var destinationAccount: Account?
    
    init(bill: Bill, billDetail: BillDetail) {
        self.bill = bill
        self.billDetail = billDetail
    }
    
    func update(accounts: [Account]) {
        self.accounts = accounts
    }
}

extension ChangeDirectDebitOperativeData: OperativeParameter {}
