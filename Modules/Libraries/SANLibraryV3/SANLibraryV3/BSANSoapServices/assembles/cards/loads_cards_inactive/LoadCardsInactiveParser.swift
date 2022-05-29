import Foundation
import Fuzi

public class LoadCardsInactiveParser : BSANParser<LoadCardsInactiveResponse, LoadCardsInactiveHandler> {
    override func setResponseData(){
        response.inactiveCards = handler.inactiveCards
    }
}

public class LoadCardsInactiveHandler: BSANHandler {
    
    var inactiveCards: [InactiveCardDTO] = []
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "lista":
            inactiveCards = InactiveCardsDTOParser.parse(element)
            break
        case "info":
            break
        default:
            BSANLogger.e("LoadCardsInactiveParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
