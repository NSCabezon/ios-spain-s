import Foundation
import Fuzi

public class GetScheduledTransferDetailParser : BSANParser<GetScheduledTransferDetailResponse, GetScheduledTransferDetailHandler> {
    override func setResponseData(){
        response.transferScheduledDetailDTO = handler.transferScheduledDetailDTO
    }
}

public class GetScheduledTransferDetailHandler: BSANHandler {
    
    var transferScheduledDetailDTO = TransferScheduledDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "methodResult":
            break
        case "importe":
            transferScheduledDetailDTO.transferAmount = AmountDTOParser.parse(element)
            break
        case "concepto":
            transferScheduledDetailDTO.concept = element.stringValue.trim()
            break
        case "indicadorResidenciaDestinatario":
            transferScheduledDetailDTO.IndicatorResidence = element.stringValue.trim()
            break
        case "cuentaIBANBeneficiario":
            transferScheduledDetailDTO.ibanBeneficiary = IBANDTO(ibanString: element.stringValue.trim())
            break
        case "codibanOrdenante":
            transferScheduledDetailDTO.iban = IBANDTO(ibanString: element.stringValue.trim())
            break
        case "fechaInicioVigencia":
            transferScheduledDetailDTO.dateStartValidity = DateFormats.safeDate(element.stringValue)
            break
        case "fechaFinVigencia":
            transferScheduledDetailDTO.dateEndValidity = DateFormats.safeDateWithoutLimit(element.stringValue)
            break
        case "fechaProximaEjecucion":
            transferScheduledDetailDTO.dateNextExecution = DateFormats.safeDate(element.stringValue)
            break
        case "nombreBenef":
            transferScheduledDetailDTO.beneficiary = element.stringValue.trim()
            break
        case "NUMERO_DE_ACTUANTE":
            transferScheduledDetailDTO.actuanteNumber = element.stringValue.trim()
            break
        case "COD_TIPO_DE_ACTUANTE":
            transferScheduledDetailDTO.actuanteCode = element.stringValue.trim()
            break
        case "CODIGO_ALFANUM_3":
            transferScheduledDetailDTO.periodicalType =  element.stringValue.trim()
            break
        default:
            BSANLogger.e("GetScheduledTransferDetailParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
