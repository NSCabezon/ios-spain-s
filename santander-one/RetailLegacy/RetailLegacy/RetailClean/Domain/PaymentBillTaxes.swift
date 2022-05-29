import SANLegacyLibrary
struct PaymentBillTaxes: OperativeParameter {
    let issuingDescription: String
    let originAccount: Account
    let amount: Amount
    let codeEntity: String
    let reference: String
    let id: String
    let dto: PaymentBillTaxesDTO
    
    init?(from paymentBillTaxesDTO: PaymentBillTaxesDTO, originAccount: Account, amount: Amount, codeEntity: String, reference: String, id: String) {
        guard
            let issuingDescription = paymentBillTaxesDTO.issuingDescription
            else {
                return nil
        }
        self.issuingDescription = issuingDescription
        self.originAccount = originAccount
        self.amount = amount
        self.codeEntity = codeEntity
        self.reference = reference
        self.id = id
        self.dto = paymentBillTaxesDTO
    }
}
