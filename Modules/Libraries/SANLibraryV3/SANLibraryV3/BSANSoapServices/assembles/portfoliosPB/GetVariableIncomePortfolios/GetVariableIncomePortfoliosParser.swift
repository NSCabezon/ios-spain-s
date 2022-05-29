import Foundation
import Fuzi

public class GetVariableIncomePortfoliosParser : BSANParser<GetVariableIncomePortfoliosResponse, GetVariableIncomePortfoliosHandler> {
    override func setResponseData(){
        response.portfolioPBDTOs = handler.portfolioPBDTOs
    }
}

public class GetVariableIncomePortfoliosHandler: BSANHandler {
    
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
            BSANLogger.e("GetVariableIncomePortfoliosParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
