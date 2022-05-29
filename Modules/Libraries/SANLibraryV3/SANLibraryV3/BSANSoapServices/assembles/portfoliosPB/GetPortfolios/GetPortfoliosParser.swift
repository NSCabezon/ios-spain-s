import Foundation
import Fuzi

public class GetPortfoliosParser : BSANParser<GetPortfoliosResponse, GetPortfoliosHandler> {
    override func setResponseData(){
        response.portfolioPBDTOs = handler.portfolioPBDTOs
    }
}

public class GetPortfoliosHandler: BSANHandler {
    
    var portfolioPBDTOs : [PortfolioDTO] = []
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "listaCarteras":
            portfolioPBDTOs = PortfolioPBDTOsParser.parse(element)
            break
         default:
            BSANLogger.e("GetPortfoliosParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
