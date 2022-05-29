import CoreDomain

public struct TransferNationalDTO {
    public var issueDate: Date?
    public var transferAmount: AmountDTO?
    public var bankChargeAmount: AmountDTO?
    public var expensesAmount: AmountDTO?
    public var netAmount: AmountDTO?
    public var destinationAccountDescription: String?
    public var originAccountDescription: String?
    public var payerName: String?
    public var scaRepresentable: SCARepresentable?
    public var fingerPrintFlag: FingerPrintFlag = .signature
    public var tokenSteps: String?

    public init() {}
    
    public init(issueDate: Date?,
                 transferAmount: AmountDTO?,
                 bankChargeAmount: AmountDTO?,
                 expensesAmount: AmountDTO?,
                 netAmount: AmountDTO?,
                 destinationAccountDescription: String?,
                 originAccountDescription: String?,
                 payerName: String?,
                 scaRepresentable: SCARepresentable?,
                 fingerprintFlag: String? = nil,
                 tokenSteps: String? = nil) {
        self.issueDate = issueDate
        self.transferAmount = transferAmount
        self.bankChargeAmount = bankChargeAmount
        self.expensesAmount = expensesAmount
        self.netAmount = netAmount
        self.destinationAccountDescription = destinationAccountDescription
        self.originAccountDescription = originAccountDescription
        self.payerName = payerName
        self.scaRepresentable = scaRepresentable
        if let fingerFlag = fingerprintFlag {
            self.fingerPrintFlag = fingerFlag.lowercased() == "s" ? .biometry : .signature
        }
        self.tokenSteps = tokenSteps
    }
}

extension TransferNationalDTO: TransferNationalRepresentable {
    public var bankChargeAmountRepresentable: AmountRepresentable? {
        self.bankChargeAmount
    }
}
