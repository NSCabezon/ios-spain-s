public protocol EmittedTransferDetailForPDFProtocol {
    var originAsteriskIBAN: String? { get }
    var destinyAsteriskIBAN: String? { get }
    var emisionDate: Date? { get }
    var beneficiaryName: String? { get }
    var feesEntity: AmountEntity? { get }
    var fees: String? { get }
    var totalAmountEntity: AmountEntity? { get }
    var totalAmount: String? { get }
    var periodicity: String? { get }
    var beneficiaryIBAN: String { get }
    var amountToDebit: Bool { get }
}
