import Foundation
import Fuzi

class CardTransactionDTOParser: DTOParser {

    public static func parse(_ node: XMLElement) -> CardTransactionDTO {
        var cardTransactionDTO = CardTransactionDTO()
        var codMonedaCurrency: CurrencyDTO?

        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaOpera":
                    cardTransactionDTO.operationDate = DateFormats.safeDate(element.stringValue)
                case "codigoSaldo":
                    cardTransactionDTO.balanceCode = element.stringValue.trim()
                case "fechaAnota":
                    cardTransactionDTO.annotationDate = DateFormats.safeDate(element.stringValue)
                case "movimDia":
                    cardTransactionDTO.transactionDay = element.stringValue.trim()
                case "importeMovto":
                    cardTransactionDTO.amount = AmountDTOParser.parse(element)
                case "descMovimiento":
                    cardTransactionDTO.description = element.stringValue.trim()
                case "codMoneda":
                    codMonedaCurrency = CurrencyDTO.create(element.stringValue.trim())
                default:
                    BSANLogger.e("CardTransactionDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
                if let date = cardTransactionDTO.operationDate?.string(format: "yyyy-MM-dd"), let movDay = cardTransactionDTO.transactionDay {
                    cardTransactionDTO.identifier = date + "_" + movDay
                }
            }
        }

        if let amount = cardTransactionDTO.amount {
            cardTransactionDTO.originalCurrency = amount.currency
            cardTransactionDTO.amount?.currency = codMonedaCurrency
        }
        return cardTransactionDTO
    }
}
