//

import Foundation
import Fuzi

public class AccountEasyPayParser: BSANParser<AccountEasyPayResponse, AccountEasyPayHandler> {
        
    override func setResponseData(){
        response.campaigns = handler.campaigns
    }
}

public class AccountEasyPayHandler: BSANHandler {
    
    fileprivate var campaigns: [AccountEasyPayDTO] = []
    
    override func parseResult(result: XMLElement) throws {
        let limits = result.firstChild(tag: "lista")
        try limits?.children.forEach(parseElement)
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let campaignCode = element.firstChild(tag: "campania")?.firstChild(tag: "COD_ALFANUM_6")?.stringValue, let limitAmountNode = element.firstChild(tag: "limite") else { return }
        let grantedAmount = AmountDTOParser.parse(limitAmountNode)
        campaigns.append(AccountEasyPayDTO(campaignCode: campaignCode, grantedAmount: grantedAmount))
    }
}


