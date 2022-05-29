import Foundation
import Fuzi

public class GetCardDataParser : BSANParser<GetCardDataResponse, GetCardDataHandler> {
    override func setResponseData(){
        response.cardDataDTOs = handler.cardDataDTOs
        response.reposDatosTarjeta = handler.reposDatosTarjeta
    }
}

public class GetCardDataHandler: BSANHandler {
    
    var cardDataDTOs: [CardDataDTO] = []
    var reposDatosTarjeta: ReposDatosTarjeta = ReposDatosTarjeta()
        
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "repos":
            reposDatosTarjeta = ReposDatosTarjetaParser.parse(element)
        case "lista":
            cardDataDTOs = CardDataDTOsParser.parse(element)
        default:
            BSANLogger.e("GetCardDataParser", "Nodo Sin Parsear! -> \(element.tag!)")
        }
    }
    
}
