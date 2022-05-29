import Foundation
import Fuzi

public class GetCardDetailTokenParser : BSANParser <GetCardDetailTokenResponse, GetCardDetailTokenHandler> {
    override func setResponseData(){
        response.cardDetailTokenDTO = handler.cardDetailTokenDTO
    }
}

public class GetCardDetailTokenHandler: BSANHandler {
    
    var cardDetailTokenDTO = CardDetailTokenDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "detalleTarjeta":
            if let codAplic = element.firstChild(tag: "codAplic"){
                cardDetailTokenDTO.codAplic = codAplic.stringValue.trim()
            }
        case "token":
            cardDetailTokenDTO.token = element.stringValue.trim()
        default:
            BSANLogger.e("GetCardDetailTokenHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
