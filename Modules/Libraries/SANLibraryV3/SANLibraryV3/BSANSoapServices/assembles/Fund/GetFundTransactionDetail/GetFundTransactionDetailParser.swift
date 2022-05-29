import Foundation
import Fuzi

public class GetFundTransactionDetailParser : BSANParser <GetFundTransactionDetailResponse, GetFundTransactionDetailHandler> {
    override func setResponseData(){
        response.fundTransactionDetailDTO = handler.fundTransactionDetailDTO
    }
}

public class GetFundTransactionDetailHandler: BSANHandler {
    
    var fundTransactionDetailDTO = FundTransactionDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "descTipoOperacion":
            fundTransactionDetailDTO.operationTypeDesc = element.stringValue.trim()
        case "impGastosOperacion":
            fundTransactionDetailDTO.operationExpensesAmount = AmountDTOParser.parse(element)
        case "descSituacion":
            fundTransactionDetailDTO.situationDesc = element.stringValue.trim()
        case "impOperacion":
            fundTransactionDetailDTO.impOperation = AmountDTOParser.parse(element)
        case "IBANCargoAbono":
            fundTransactionDetailDTO.IBANChargeIncome = IBANDTOParser.parse(element)
        case "descIBANCargoAbono":
            fundTransactionDetailDTO.descIBANChargeIncome = element.stringValue.trim()
        default:
            BSANLogger.e("FundDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}

