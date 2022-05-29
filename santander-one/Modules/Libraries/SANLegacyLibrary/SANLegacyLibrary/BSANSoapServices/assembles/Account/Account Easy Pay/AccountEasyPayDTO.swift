//

import CoreDomain

public struct AccountEasyPayDTO: Codable  {
    public let campaignCode: String
    public let grantedAmount: AmountDTO
    
    public init(campaignCode: String, grantedAmount: AmountDTO){
        self.campaignCode = campaignCode
        self.grantedAmount = grantedAmount
    }
}

extension AccountEasyPayDTO: AccountEasyPayRepresentable {
    public var grantedAmountRepresentable: AmountRepresentable {
        return grantedAmount
    }
}
