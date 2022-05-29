import SANLegacyLibrary

struct BillDetail {
    
    static func create(_ from: BillDetailDTO) -> BillDetail {
        return BillDetail(dto: from)
    }
    
    let billDetailDTO: BillDetailDTO
    
    internal init(dto: BillDetailDTO) {
        billDetailDTO = dto
    }
    
    var holder: String {
        return billDetailDTO.holder
    }
    
    var holderNIF: String {
        return billDetailDTO.holderNIF
    }
    var debtorAccount: String {
        return billDetailDTO.debtorAccount
    }
    
    var billNumber: String {
        return billDetailDTO.billNumber
    }
    var concept: String? {
        return billDetailDTO.concept
    }
    var amount: Amount {
        return Amount.createFromDTO(billDetailDTO.amount)
    }
    var chargeDate: Date {
        return billDetailDTO.chargeDate
    }
    var mandateReference: String {
        return billDetailDTO.mandateReference
    }
    var sourceNIFSurf: String {
        return billDetailDTO.sourceNIFSurf
    }
    var status: BillStatusDO {
        return BillStatusDO(from: billDetailDTO.state)
    }
    
    var accountRefundDescription: String {
        return billDetailDTO.accountRefundDescription
    }
    var issuerName: String {
        return billDetailDTO.issuerName
    }
    
    var reference: String {
        return billDetailDTO.reference
    }
    
    var statusDescription: String {
        return billDetailDTO.stateDescription
    }
    
    var signature: Signature {
        return Signature(dto: billDetailDTO.signature)
    }
}

extension BillDetail: GenericTransactionProtocol {}

extension BillDetail: GenericProductProtocol {}
