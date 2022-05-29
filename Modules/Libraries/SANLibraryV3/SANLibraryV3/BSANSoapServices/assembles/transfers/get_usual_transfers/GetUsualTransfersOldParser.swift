import Foundation
import Fuzi

public class GetUsualTransfersOldParser : BSANParser<GetUsualTransfersResponse, GetUsualTransfersOldHandler> {
    override func setResponseData(){
        response.payeeDTOs = handler.payeeDTOs
    }
}

public class GetUsualTransfersOldHandler: BSANHandler {
    var payeeDTOs: [PayeeDTO] = []
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "lista":
            payeeDTOs = PayeeDTOsParser.parse(element)
            break
        default:
            BSANLogger.e("GetUsualTransfersParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
