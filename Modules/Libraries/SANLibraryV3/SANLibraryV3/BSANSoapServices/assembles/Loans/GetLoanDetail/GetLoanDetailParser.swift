import Foundation

import Fuzi

public class GetLoanDetailParser : BSANParser <GetLoanDetailResponse, GetLoanDetailHandler> {
    override func setResponseData(){
        response.loanDetailDTO = handler.loanDetailDTO
    }
}

public class GetLoanDetailHandler: BSANHandler {
    
    var loanDetailDTO = LoanDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "titular":
            loanDetailDTO.holder = element.stringValue.trim()
        case "impCapitalInicial":
            loanDetailDTO.initialAmount = AmountDTOParser.parse(element)
        case "tipoDeInteres":
            loanDetailDTO.interestType = element.stringValue.trim()
        case "descTipoDeInteres":
            loanDetailDTO.interestTypeDesc = element.stringValue.trim()
        case "descPerioricidadCuotas":
            loanDetailDTO.feePeriodDesc = element.stringValue.trim()
        case "fechaApertura":
            loanDetailDTO.openingDate = DateFormats.safeDate(element.stringValue)
        case "fechaVencimientoInicial":
            loanDetailDTO.initialDueDate = DateFormats.safeDate(element.stringValue)
        case "fechaVencimientoActual":
            loanDetailDTO.currentDueDate = DateFormats.safeDate(element.stringValue)
        case "cuentaAsociada":
            loanDetailDTO.linkedAccountContract = ContractDTOParser.parse(element)
        case "descCuentaAsociada":
            loanDetailDTO.linkedAccountDesc = element.stringValue.trim()
        default:
            BSANLogger.e("AccountDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
