public protocol SavingTransactionParamsRepresentable {
    var accountID: String { get }
    var type: String? { get }
    var contract: ContractRepresentable? { get }
    var fromBookingDate: Date? { get }
    var toBookingDate: Date? { get }
    var offset: String? { get }
}
