import Foundation
import Fuzi

public class ConfirmFundSubscriptionParser : BSANParser <ConfirmFundSubscriptionResponse, ConfirmFundSubscriptionHandler> {
    override func setResponseData(){
        response.fundSubscriptionConfirmDTO = handler.fundSubscriptionConfirmDTO
    }
}

public class ConfirmFundSubscriptionHandler: BSANHandler {
    
    var fundSubscriptionConfirmDTO = FundSubscriptionConfirmDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let fechaCargoCta = result.firstChild(tag: "fechaCargoCta"){
            fundSubscriptionConfirmDTO.accountChargeDate = DateFormats.safeDate(fechaCargoCta.stringValue)
        }
        if let fechaSolic = result.firstChild(tag: "fechaSolic"){
            fundSubscriptionConfirmDTO.applyDate = DateFormats.safeDate(fechaSolic.stringValue)
        }
    }
}
