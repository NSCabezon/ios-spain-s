public protocol ProprietaryBankSavingTransactionCodeRepresentable {
    var code: String { get }
    var issuer: String? { get }
}
