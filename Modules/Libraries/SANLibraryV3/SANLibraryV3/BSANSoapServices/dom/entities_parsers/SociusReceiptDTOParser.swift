import Foundation
import Fuzi
import SANLegacyLibrary

class SociusReceiptDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SociusReceiptDTO {
        var sociusReceiptDTO = SociusReceiptDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "codigo":
                    sociusReceiptDTO.code = element.stringValue.trim()
                    break
                case "descripcion":
                    sociusReceiptDTO.description = element.stringValue.trim()
                    break
                case "importeUltimaLiquidacion":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusReceiptDTO.lastLiquidationAmount = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "totalAcumulado":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusReceiptDTO.totalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "fechaDesde":
                    sociusReceiptDTO.startDate = DateFormats.safeDateTimeZ(element.stringValue)
                    break
                case "fechaHasta":
                    sociusReceiptDTO.endDate = DateFormats.safeDateTimeZ(element.stringValue)
                    break
                case "detalleLineaRecibo":
                    let receiptDetail = SociusReceiptDetailDTOParser.parse(element)
                    sociusReceiptDTO.sociusReceiptDetailDTOList.append(receiptDetail)
                    break
                default:
                    BSANLogger.e("SociusReceiptDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return sociusReceiptDTO
    }
}
