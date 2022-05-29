import Foundation
import Fuzi

public class ActivateCardParser : BSANParser <ActivateCardResponse, ActivateCardHandler> {
    override func setResponseData(){
        response.activateCardDTO = handler.activateCardDTO
    }
}

public class ActivateCardHandler: BSANHandler {
    
    var activateCardDTO = ActivateCardDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
            
        case "datosFirma":
            activateCardDTO.scaRepresentable = SignatureDTOParser.parse(element)
        default:
            BSANLogger.e("ActivateCardHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
