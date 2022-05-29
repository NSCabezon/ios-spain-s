import Foundation
import Fuzi
import SANLegacyLibrary

class SociusLiquidationDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> SociusLiquidationDTO {
        var sociusLiquidationDTO = SociusLiquidationDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "abonadoCuentaUltimaLiquidacion":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.accountPaidLastLiquidation = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "abonadoCuentaTotalAcumulado":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.accountPaidTotalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "interesesTotalAcumulado":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.interestsTotalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "interesesUltimaLiquidacion":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.interestsLastLiquidation = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "CashbackUltimaLiquidacion":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.cashbackLastLiquidation = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "CashbackTotalAcumulado":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.cashbackTotalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "recibos":
                    let receipt = SociusReceiptDTOParser.parse(element)
                    sociusLiquidationDTO.receipts.append(receipt)
                    break
                case "accionesUltimaLiquidacion":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.stocksLastLiquidation = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "accionesTotalAcumulado":
                    if let decimal = safeDecimal(element.stringValue) {
                        sociusLiquidationDTO.stocksTotalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
                    }
                    break
                case "accionesXProd":
                    let stock = SociusStockDTOParser.parse(element)
                    sociusLiquidationDTO.stocks.append(stock)
                    break
                case "fechaDesde":
                    sociusLiquidationDTO.startDate = DateFormats.safeDateTimeZ(element.stringValue)
                    break
                case "fechaHasta":
                    sociusLiquidationDTO.endDate = DateFormats.safeDateTimeZ(element.stringValue)
                    break
                default:
                    BSANLogger.e("SociusLiquidationDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return sociusLiquidationDTO
    }
}
