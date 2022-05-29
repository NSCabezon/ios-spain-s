import Foundation
import Fuzi

public class GetFundTransactionsParser : BSANParser <GetFundTransactionsResponse, GetFundTransactionsHandler> {
    override func setResponseData(){
		response.fundTransactionsDTO = FundTransactionsListDTO(transactionDTOs: handler.fundTransactions, pagination: handler.pagination)
        
        for i in 0 ... response.fundTransactionsDTO.transactionDTOs.count-1{
            response.fundTransactionsDTO.transactionDTOs[i].productSubtypeCode = handler.codigoSubproducto.productSubtype
        }
    }
}

public class GetFundTransactionsHandler: BSANHandler {
    
    var fundTransactions = [FundTransactionDTO]()
    var codigoSubproducto = SubproductCodeDTO()
	var pagination = PaginationDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
		case "lista":
			fundTransactions = FundTransactionsDTOParser.parse(element)
        case "finLista":
            pagination.endList = DTOParser.safeBoolean(element.stringValue.trim())
		case "repos":
			pagination.repositionXML = element.rawXML.trim()
        case "codigoSubproducto":
            codigoSubproducto = SubproductCodeDTOParser.parse(element)
        default:
           BSANLogger.e("FundTransactionsHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}

