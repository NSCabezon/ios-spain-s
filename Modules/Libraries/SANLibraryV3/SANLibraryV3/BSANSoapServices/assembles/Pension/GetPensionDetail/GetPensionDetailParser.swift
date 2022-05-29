import Foundation

import Fuzi

public class GetPensionDetailParser : BSANParser <GetPensionDetailResponse, GetPensionDetailHandler> {
    override func setResponseData(){
        response.pensionDetailDTO = handler.pensionDetailDTO
    }
}

public class GetPensionDetailHandler: BSANHandler {
    
    var pensionDetailDTO = PensionDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "fechaValoracion":
            pensionDetailDTO.valueDate = DateFormats.safeDate(element.stringValue)
        case "numParticipac":
            pensionDetailDTO.sharesNumber = DTOParser.safeDecimal(element.stringValue.trim())
        case "impDerechosConsolid":
            pensionDetailDTO.vestedRightsAmount = AmountDTOParser.parse(element)
        case "impValoracion":
            pensionDetailDTO.settlementValueAmount = AmountDTOParser.parse(element)
        case "descPlan":
            pensionDetailDTO.pensionDesc = element.stringValue.trim()
        case "cuentaAsociada":
            pensionDetailDTO.linkedAccountContract = ContractDTOParser.parse(element)
        case "descCuentaAsociada":
            pensionDetailDTO.linkedAccountDesc = element.stringValue.trim()
        case "titular":
            pensionDetailDTO.holder = element.stringValue.trim()
        default:
            BSANLogger.e("AccountDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
