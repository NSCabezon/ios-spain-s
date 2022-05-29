public protocol AccountDataRepresentable {
    var bankCode: String { get }
    var branchCode: String { get }
    var checkDigits: String { get }
    var accountNumber: String { get }
    var description: String { get }
}
