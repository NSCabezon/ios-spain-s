import Foundation
import Fuzi

public class LoadCardDetailParser : BSANParser<LoadCardDetailResponse, LoadCardDetailHandler> {
    override func setResponseData(){
        response.cardDetailDTO = handler.cardDetailDTO
    }
}

public class LoadCardDetailHandler: BSANHandler {
    
    var cardDetailDTO: CardDetailDTO = CardDetailDTO()    
 
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "info":
            break
        case "titularContr":
            cardDetailDTO.holder = element.stringValue.trim()
            break
        case "beneficiarioTarjeta":
            cardDetailDTO.beneficiary = element.stringValue.trim()
            break
        case "fechaCaducidad":
            cardDetailDTO.expirationDate = DateFormats.safeDate(element.stringValue)
            break
        case "cuentaCargo":
            cardDetailDTO.linkedAccountOldContract = ContractDTOParser.parse(element)
            break
        case "limiteCredito":
            cardDetailDTO.creditLimitAmount = AmountDTOParser.parse(element)
            break
        case "importeSalDispto":
            cardDetailDTO.currentBalance =  AmountDTOParser.parse(element)
            break
        case "importeSalDisponible":
            cardDetailDTO.availableAmount =  AmountDTOParser.parse(element)
            break
        case "limiteCompra":
            cardDetailDTO.purchaseLimitAmount =  AmountDTOParser.parse(element)
            break
        case "descTipoTarjeta":
            cardDetailDTO.cardTypeDescription = element.stringValue.trim()
            break
        case "descCuentaCargo":
            cardDetailDTO.linkedAccountDescription = element.stringValue.trim()
            break
        case "limiteOffLine":
            cardDetailDTO.offLineLimitAmount =  AmountDTOParser.parse(element)
            break
        case "limiteOnLine":
            cardDetailDTO.onLineLimitAmount =  AmountDTOParser.parse(element)
            break
        case "tipoSituacion":
            cardDetailDTO.statusType =  element.stringValue.trim()
            break
        case "divisa":
            cardDetailDTO.currency =  element.stringValue.trim()
            break
        case "numeroCuentaTarjetaCredito":
            cardDetailDTO.creditCardAccountNumber =  element.stringValue.trim()
            break
        case "seguro":
            cardDetailDTO.insurance =  element.stringValue.trim()
            break
        default:
            BSANLogger.e("LoadCardDetailParser", "Nodo Sin Parsear! -> \(tag)")
        }        
    }
    
}
