import Foundation
import Fuzi

class CardsListApplePayStatusParser: BSANParser<CardsListApplePayStatusResponse, CardsListApplePayStatusHandler> {
    override func setResponseData() {
        response.panStatusList = handler.panStatusList
    }
}

class CardsListApplePayStatusHandler: BSANHandler {
    fileprivate var panStatusList: [String: CardApplePayStatusDTO]?
    
    override func parseResult(result: XMLElement) throws {
        guard let listInfoDevice = result.firstChild(tag: "listInfoDeviceAccountIdentifier")?.children(tag: "infoDeviceAccountIdentifier") else {
            return
        }
        var panStatusList: [String: CardApplePayStatusDTO] = [:]
        for infoDevice in listInfoDevice {
            if let statusTk = infoDevice.firstChild(tag: "statusTk")?.stringValue,
                let status = CardApplePayStatusDTO.Status(rawValue: statusTk),
                let pan = infoDevice.firstChild(tag: "panTk")?.stringValue
            {
                panStatusList[pan] = CardApplePayStatusDTO(status: status)
            }
        }
        self.panStatusList = panStatusList
    }
}


