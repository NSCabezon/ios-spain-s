import Foundation
import Fuzi

public class GetProductTransactionDetailParser : BSANParser <GetProductTransactionDetailResponse, GetProductTransactionDetailHandler> {
    override func setResponseData(){
        response.portfolioTransactionDetailDTO = handler.portfolioTransactionDetailDTO
    }
}

public class GetProductTransactionDetailHandler: BSANHandler {
    
    var portfolioTransactionDetailDTO = PortfolioTransactionDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        
        guard let tag = element.tag else { return }
        switch tag {
        case "fechaOperacion":
            portfolioTransactionDetailDTO.operationDate = DateFormats.safeDate(element.stringValue)
        case "numParticipaciones":
            portfolioTransactionDetailDTO.sharesCount = DTOParser.safeDecimal(element.stringValue.trim())
        case "impMovimiento":
            portfolioTransactionDetailDTO.amount = AmountDTOParser.parse(element)
        case "fechaValor":
            portfolioTransactionDetailDTO.valueDate = DateFormats.safeDate(element.stringValue)
        case "tipoOperacion":
            portfolioTransactionDetailDTO.transactionType = element.stringValue.trim()
        case "descCuentaAsociada":
            portfolioTransactionDetailDTO.linkedAccountDesc = element.stringValue.trim()
        case "impGastos":
            portfolioTransactionDetailDTO.expensesAmount = AmountDTOParser.parse(element)
        default:
            BSANLogger.e("\(String.init(describing: self))", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
