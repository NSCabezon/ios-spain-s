import Foundation
import Fuzi

public class GetPortfolioProductsParser : BSANParser <GetPortfolioProductsResponse, GetPortfolioProductsHandler> {
    override func setResponseData(){
        response.portfolioProductPBDTOs = handler.portfolioProductPBDTOs
    }
}

public class GetPortfolioProductsHandler: BSANHandler {
    
    var portfolioProductPBDTOs = [PortfolioProductDTO]()
    
    override func parseElement(element: XMLElement) throws {
        
        guard let tag = element.tag else { return }
        switch tag {
        case "listaValoresPorCartera":

            if element.children(tag: "dato").count == 0{
                break
            }

            for i in 0 ... element.children(tag: "dato").count-1{
                let childElement = element.children(tag: "dato")[i]
                let portfolioProductPBDTO = PortfolioProductPBDTOParser.parse(childElement)

                portfolioProductPBDTOs.append(portfolioProductPBDTO)
            }

        default:
            BSANLogger.e("\(String.init(describing: self))", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
