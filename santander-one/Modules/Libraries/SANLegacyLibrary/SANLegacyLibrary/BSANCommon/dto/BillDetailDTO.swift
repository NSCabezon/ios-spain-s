import Foundation

public struct BillDetailDTO {
    public let signature: SignatureDTO
    public let holder: String
    public let issuerName: String
    public let holderNIF: String
    public let debtorAccount: String
    public let reference: String
    public let billNumber: String
    public let concept: String?
    public let amount: AmountDTO
    public let chargeDate: Date
    public let mandateReference: String
    public let sourceNIFSurf: String
    public let state: BillStatus
    public let stateDescription: String
    public let accountRefundDescription: String
    public let productSubtype: ProductSubtypeDTO
    
    public init(
        signature: SignatureDTO,
        holder: String,
        issuerName: String,
        holderNIF: String,
        debtorAccount: String,
        reference: String,
        billNumber: String,
        concept: String?,
        amount: AmountDTO,
        chargeDate: Date,
        mandateReference: String,
        sourceNIFSurf: String,
        state: BillStatus,
        stateDescription: String,
        accountRefundDescription: String,
        productSubtype: ProductSubtypeDTO
    ) {
        self.signature = signature
        self.holder = holder
        self.issuerName = issuerName
        self.holderNIF = holderNIF
        self.debtorAccount = debtorAccount
        self.reference = reference
        self.billNumber = billNumber
        self.concept = concept
        self.amount = amount
        self.chargeDate = chargeDate
        self.mandateReference = mandateReference
        self.sourceNIFSurf = sourceNIFSurf
        self.state = state
        self.stateDescription = stateDescription
        self.accountRefundDescription = accountRefundDescription
        self.productSubtype = productSubtype
    }
}
