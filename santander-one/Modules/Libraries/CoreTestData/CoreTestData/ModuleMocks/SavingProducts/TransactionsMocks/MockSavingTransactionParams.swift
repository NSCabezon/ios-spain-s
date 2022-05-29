import CoreDomain
import OpenCombine

struct MockSavingTransactionParams: SavingTransactionParamsRepresentable {
    let accountID: String
    var type: String?
    var contract: ContractRepresentable?
    let fromBookingDate: Date?
    let toBookingDate: Date?
    let offset: String?
    
    init(accountID: String,
         fromBookingDate: Date? = nil,
         toBookingDate: Date? = nil,
         offset: String? = nil,
         type: String? = nil,
         contract: ContractRepresentable? = nil) {
        self.accountID = accountID
        self.fromBookingDate = fromBookingDate
        self.toBookingDate = toBookingDate
        self.offset = offset
        self.type = type
        self.contract = contract
    }
}
