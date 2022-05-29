import Foundation
import Fuzi

public class GetFundDetailParser : BSANParser <GetFundDetailResponse, GetFundDetailHandler> {
    override func setResponseData(){
        response.fundDetailDTO = handler.fundDetailDTO
    }
}

public class GetFundDetailHandler: BSANHandler {
    
    var fundDetailDTO = FundDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "titular":
            fundDetailDTO.holder = element.stringValue.trim()
        case "descFondo":
            fundDetailDTO.fundDesc = element.stringValue.trim()
        case "valorLiquidativoParticipac":
            fundDetailDTO.settlementValueAmount = AmountDTOParser.parse(element)
        case "valorTotal":
            fundDetailDTO.valueAmount = AmountDTOParser.parse(element)
        case "fechaValor":
            fundDetailDTO.valueDate = DateFormats.safeDate(element.stringValue)
        case "numParticipac":
            fundDetailDTO.sharesNumber = DTOParser.safeDecimal(element.stringValue.trim())
        case "cuentaAsociada":
            fundDetailDTO.linkedAccount = ContractDTOParser.parse(element)
        case "descCuentaAsociada":
            fundDetailDTO.linkedAccountDesc = element.stringValue.trim()
        default:
            BSANLogger.e("FundDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}

