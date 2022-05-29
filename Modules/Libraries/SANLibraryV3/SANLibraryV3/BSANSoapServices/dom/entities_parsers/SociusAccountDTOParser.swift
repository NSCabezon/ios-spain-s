import Foundation
import Fuzi

class SociusAccountDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SociusAccountDTO {
        var sociusAccountDTO = SociusAccountDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "cuenta":
                    sociusAccountDTO.account = element.stringValue.trim()
                    break
                case "tipoCuenta":
                    sociusAccountDTO.accountType = SociusAccountType.findBy(type: element.stringValue.trim())
                    break
                case "estadoCuenta":
                    sociusAccountDTO.sociusAccountStateDTO = SociusAccountStateDTOParser.parse(element)
                    break
                case "cumplimientoCuenta":
                    sociusAccountDTO.accountFulfillment = SociusFulfillmentDTOParser.parse(element)
                    break
                case "cumplimientoRecibos":
                    sociusAccountDTO.receiptsFulfillment = SociusFulfillmentDTOParser.parse(element)
                    break
                case "cumplimientoTarjetas":
                    sociusAccountDTO.cardsFulfillment = SociusFulfillmentDTOParser.parse(element)
                    break
                case "liquidacion":
                    sociusAccountDTO.sociusLiquidation = SociusLiquidationDTOParser.parse(element)
                    break
                case "fiscalidad":
                    sociusAccountDTO.taxationDTO = TaxationDTOParser.parse(element)
                    break
                default:
                    BSANLogger.e("SociusAccountDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return sociusAccountDTO
    }
}
