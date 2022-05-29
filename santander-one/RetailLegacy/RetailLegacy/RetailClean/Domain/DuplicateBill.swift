import SANLegacyLibrary

struct DuplicateBill { 
    let dto: DuplicateBillDTO
    
    var signature: Signature {
        return Signature(dto: dto.signature)
    }
    var reference: String? {
        return dto.reference
    }
    var concept: String? {
        return dto.concept
    }
    var datePayment: Date? {
        return dto.datePayment
    }
}
