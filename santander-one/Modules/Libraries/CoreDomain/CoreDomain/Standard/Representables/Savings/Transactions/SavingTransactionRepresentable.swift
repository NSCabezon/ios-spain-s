public protocol SavingTransactionRepresentable {
    var accountId: String { get }
    var transactionId: String? { get }
    var transactionReference: String? { get }
    var amount: SavingAmountRepresentable { get }
    var creditDebitIndicator: String { get }
    var status: String { get }
    var transactionMutability: String { get }
    var bookingDateTime: Date { get }
    var valueDateTime: Date? { get }
    var transactionInformation: String? { get }
    var bankTransactionCode: BankSavingTransactionCodeRepresentable? { get }
    var proprietaryBankTransactionCode: ProprietaryBankSavingTransactionCodeRepresentable? { get }
    var balance: SavingTransactionBalanceRepresentable? { get }
    var supplementaryData: SavingTransactionSupplementaryDataRepresentable? { get }
}
