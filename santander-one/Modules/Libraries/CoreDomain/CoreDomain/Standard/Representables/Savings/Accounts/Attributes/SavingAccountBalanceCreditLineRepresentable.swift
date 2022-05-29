public protocol SavingAccountBalanceCreditLineRepresentable {
    var included: String { get }
    var type: String { get }
    var amount: AmountRepresentable { get }
}
