import Foundation
import Fuzi
import SANLegacyLibrary


class SociusStockDTOParser: DTOParser {

    public static func parse(_ node: XMLElement) -> SociusStockDTO {
        var sociusStockDTO = SociusStockDTO()

        sociusStockDTO.code = node.firstChild(tag: "codigo")?.stringValue.trim()
        sociusStockDTO.description = node.firstChild(tag: "descripcion")?.stringValue.trim()

        if let decimal = safeDecimal(node.firstChild(tag: "importeUltimaLiquidacion")?.stringValue) {
            sociusStockDTO.amountLastLiquidation = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
        }
        if let decimal = safeDecimal(node.firstChild(tag: "totalAcumulado")?.stringValue) {
            sociusStockDTO.totalAccumulated = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
        }

        sociusStockDTO.startDate = DateFormats.safeDateTimeZ(node.firstChild(tag: "fechaDesde")?.stringValue)
        sociusStockDTO.endDate = DateFormats.safeDateTimeZ(node.firstChild(tag: "fechaHasta")?.stringValue)

        return sociusStockDTO
    }
}
