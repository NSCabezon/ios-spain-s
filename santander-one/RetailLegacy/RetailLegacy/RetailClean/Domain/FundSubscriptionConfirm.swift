import SANLegacyLibrary

class FundSubscriptionConfirm: GenericProduct {
    
    static func create(_ from: FundSubscriptionConfirmDTO) -> FundSubscriptionConfirm {
        return FundSubscriptionConfirm(dto: from)
    }
    
    private(set) var fundSubscriptionConfirmDTO: FundSubscriptionConfirmDTO
    
    internal init(dto: FundSubscriptionConfirmDTO) {
        fundSubscriptionConfirmDTO = dto
        super.init()
    }
}

extension FundSubscriptionConfirm: OperativeParameter {}
