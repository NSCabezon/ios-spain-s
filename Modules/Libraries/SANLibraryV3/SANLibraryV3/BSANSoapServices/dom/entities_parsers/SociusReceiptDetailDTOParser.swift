import Foundation
import Fuzi
import SANLegacyLibrary


class SociusReceiptDetailDTOParser: DTOParser {

    public static func parse(_ node: XMLElement) -> SociusReceiptDetailDTO {
        var sociusReceiptDetailDTO = SociusReceiptDetailDTO()
        sociusReceiptDetailDTO.cif = node.firstChild(tag: "cif")?.stringValue.trim()
        sociusReceiptDetailDTO.cifDesc = node.firstChild(tag: "descCif")?.stringValue.trim()
        sociusReceiptDetailDTO.lastLiquidationReceiptsCount = safeInteger(node.firstChild(tag: "numReciboUl")?.stringValue)

        if let decimal = safeDecimal(node.firstChild(tag: "ultimaLiq")?.stringValue) {
            sociusReceiptDetailDTO.lastLiquidationAmount = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
        }

        sociusReceiptDetailDTO.totalLiquidationReceiptsCount = safeInteger(node.firstChild(tag: "numReciboTl")?.stringValue)

        if let decimal = safeDecimal(node.firstChild(tag: "totalLiq")?.stringValue) {
            sociusReceiptDetailDTO.totalLiquidationAmount = AmountDTO(value: decimal, currency: CurrencyDTO.create(SharedCurrencyType.default))
        }

        return sociusReceiptDetailDTO
    }
}
