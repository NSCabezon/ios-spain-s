import SANLegacyLibrary

class FundSubscription: GenericProduct {
    
    static func create(_ from: FundSubscriptionDTO) -> FundSubscription {
        return FundSubscription(dto: from)
    }
    
    private(set) var fundSubscriptionDTO: FundSubscriptionDTO
    
    var ibanPapel: String {
        guard let ibanDTO = fundSubscriptionDTO.directDebtAccount else { return "" }
        
        let iban = IBAN.create(ibanDTO)
        return iban.ibanPapel
    }
    
    var ccc: String {
        guard let ibanDTO = fundSubscriptionDTO.directDebtAccount else { return "" }
        
        let iban = IBAN.create(ibanDTO)
        return iban.ccc
    }
    
    var signature: Signature? {
        guard let signature = fundSubscriptionDTO.signature else {
            return nil
        }
        return Signature(dto: signature)
    }
    
    internal init(dto: FundSubscriptionDTO) {
        fundSubscriptionDTO = dto
        super.init()
    }
}

extension FundSubscription: OperativeParameter {}
