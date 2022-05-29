import Foundation
import Fuzi

public class GetEmittedTransferDetailParser : BSANParser<GetEmittedTransferDetailResponse, GetEmittedTransferDetailHandler> {
    override func setResponseData(){
        response.transferEmittedDetailDTO = handler.transferEmittedDetailDTO
    }
}

public class GetEmittedTransferDetailHandler: BSANHandler {
    
    var transferEmittedDetailDTO = TransferEmittedDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "methodResult":
            break
        case "cuentaCargo":
            transferEmittedDetailDTO.origin = IBANDTO(ibanString: element.stringValue.trim())
            break
        case "cuentaAbono":
            transferEmittedDetailDTO.beneficiary = IBANDTO(ibanString: element.stringValue.trim())
            break
        case "importe":
            transferEmittedDetailDTO.transferAmount = AmountDTOParser.parse(element)
            break
        case "importeComisiones":
            transferEmittedDetailDTO.banckCharge = AmountDTOParser.parse(element)
            break
        case "importeTotal":
            transferEmittedDetailDTO.netAmount = AmountDTOParser.parse(element)
            break
        case "fechaEmision":
            transferEmittedDetailDTO.emisionDate = DateFormats.safeDate(element.stringValue)
            break
        case "fechaValor":
            transferEmittedDetailDTO.valueDate = DateFormats.safeDate(element.stringValue)
            break
        case "nombreOrdenante":
            transferEmittedDetailDTO.originName = element.stringValue.trim()
            break
        case "nombreBeneficiario":
            transferEmittedDetailDTO.beneficiaryName = element.stringValue.trim()
            break
        case "indicadorGastos":
            transferEmittedDetailDTO.spentIndicator = element.stringValue.trim()
            break
        case "tipoTransferencia":
            transferEmittedDetailDTO.transferType = element.stringValue.trim()
            break
        case "paisDestino":
            transferEmittedDetailDTO.countryCode = element.stringValue.trim()
            break
        case "descIndicadorGastos":
            transferEmittedDetailDTO.spentDescIndicator = element.stringValue.trim()
            break
        case "descTipoTransferencia":
            transferEmittedDetailDTO.descTransferType = element.stringValue.trim()
            break
        case "descPaisDestino":
            transferEmittedDetailDTO.countryName = element.stringValue.trim()
            break
        default:
            BSANLogger.e("GetEmittedTransferDetailParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
    
}
