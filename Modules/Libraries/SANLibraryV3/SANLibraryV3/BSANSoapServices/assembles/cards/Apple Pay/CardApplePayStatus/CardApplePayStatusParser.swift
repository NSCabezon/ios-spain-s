import Foundation
import Fuzi

public class CardApplePayStatusParser: BSANParser<CardApplePayStatusResponse, CardApplePayStatusHandler> {
        
    override func setResponseData() {
        response.status = handler.response
    }
}

public class CardApplePayStatusHandler: BSANHandler {
    
    fileprivate var response: CardApplePayStatusDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard
            let status = result.firstChild(tag: "status")?.stringValue,
            let statusModel = CardApplePayStatusDTO.Status(rawValue: status)
        else {
            return
        }
        self.response = CardApplePayStatusDTO(status: statusModel)
    }
}


