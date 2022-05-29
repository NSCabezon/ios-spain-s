class DuplicateBillOperativeData {
    let bill: Bill
    var account: Account?
    var duplicateBill: DuplicateBill?
    
    init(bill: Bill) {
        self.bill = bill
    }
    
    func update(account: Account, duplicateBill: DuplicateBill) {
        self.account = account
        self.duplicateBill = duplicateBill
    }
}

extension DuplicateBillOperativeData: OperativeParameter {}
