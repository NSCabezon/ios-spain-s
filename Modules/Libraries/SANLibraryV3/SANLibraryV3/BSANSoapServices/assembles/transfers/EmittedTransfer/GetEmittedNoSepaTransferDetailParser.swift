import Foundation
import Fuzi

public class GetEmittedNoSepaTransferDetailParser: BSANParser<GetEmittedNoSepaTransferDetailResponse, GetEmittedNoSepaTransferDetailHandler> {
    override func setResponseData(){
        response.noSepaTransferEmittedDetailDTO = handler.noSepaTransferEmittedDetailDTO
    }
}

public class GetEmittedNoSepaTransferDetailHandler: BSANHandler {
    
    var noSepaTransferEmittedDetailDTO = NoSepaTransferEmittedDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "methodResult":
            break
        case "generales":
            if let cuentaCargo = element.firstChild(tag: "cuentaCargo") {
                noSepaTransferEmittedDetailDTO.origin = IBANDTO(ibanString: cuentaCargo.stringValue.trim())
            }
            
            if let transferAmount = element.firstChild(tag: "importe") {
                noSepaTransferEmittedDetailDTO.transferAmount = AmountDTOParser.parse(transferAmount)
            }
            
            if let emisionDate = element.firstChild(tag: "fechaEmision") {
                noSepaTransferEmittedDetailDTO.emisionDate = DateFormats.safeDate(emisionDate.stringValue)
            }
            
            if let valueDate = element.firstChild(tag: "fechaValor") {
                noSepaTransferEmittedDetailDTO.valueDate = DateFormats.safeDate(valueDate.stringValue)
            }
            
            if let originName = element.firstChild(tag: "nombreOrdenante") {
                noSepaTransferEmittedDetailDTO.originName = originName.stringValue.trim()
            }
            
            if let spentIndicator = element.firstChild(tag: "indicadorGastos"), let spentIndicatorByAccount = spentIndicator.firstChild(tag: "INDICADOR_GASTOS_POR_CTA") {
                noSepaTransferEmittedDetailDTO.expensesIndicator = spentIndicatorByAccount.stringValue.trim()
            }
            
            if let transferType = element.firstChild(tag: "tipoTransferencia") {
                noSepaTransferEmittedDetailDTO.transferType = transferType.stringValue.trim()
            }
            
            if let countryCode = element.firstChild(tag: "paisDestino") {
                noSepaTransferEmittedDetailDTO.countryCode = countryCode.stringValue.trim()
            }
            
            if let concept1 = element.firstChild(tag: "concepto1") {
                noSepaTransferEmittedDetailDTO.concept1 = concept1.stringValue.trim()
            }
            
            if let spentDescIndicator = element.firstChild(tag: "descIndicadorGastos") {
                noSepaTransferEmittedDetailDTO.spentDescIndicator = spentDescIndicator.stringValue.trim()
            }
            
            if let descTransferType = element.firstChild(tag: "descTipoTransferencia") {
                noSepaTransferEmittedDetailDTO.descTransferType = descTransferType.stringValue.trim()
            }
            if let countryName = element.firstChild(tag: "descPaisDestino") {
                noSepaTransferEmittedDetailDTO.countryName = countryName.stringValue.trim()
            }
            break
        case "beneficiario":
            noSepaTransferEmittedDetailDTO.payee = NoSepaPayeeDTOParser.parse(element)
            break
        case "ordenante":
            noSepaTransferEmittedDetailDTO.entityAuthPayment = EntityAuthPaymentDTOParser.parse(element)
            break
        default:
            BSANLogger.e("GetEmittedTransferDetailParser", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}


