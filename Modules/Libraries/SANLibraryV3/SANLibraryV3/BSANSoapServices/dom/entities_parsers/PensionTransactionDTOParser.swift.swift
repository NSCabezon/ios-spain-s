import Foundation
import Fuzi

class PensionTransactionDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> PensionTransactionDTO {
        var pensionTransactionDTO = PensionTransactionDTO()

        var amountValue = "00"
        var currencyValue = "NOCURRENCY"
        var sharesValue = "00"
        var descValue = "NODESC"
        var dateValue = "NODATE"

        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "impMovimiento":
                    pensionTransactionDTO.amount = AmountDTOParser.parse(element)
                    if let amount = pensionTransactionDTO.amount?.value {
                        amountValue = "\(amount)"
                    }
                    if let currency = pensionTransactionDTO.amount?.currency?.currencyName {
                        currencyValue = "\(currency)"
                    }
                case "fechaOperacion":
                    pensionTransactionDTO.operationDate = DateFormats.safeDate(element.stringValue)
                    if let date = pensionTransactionDTO.operationDate {
                        dateValue = date.string(format: "yyyy_MM_dd")
                    }
                case "numParticipac":
                    pensionTransactionDTO.sharesCount = safeDecimal(element.stringValue)
                    if let shares = pensionTransactionDTO.sharesCount {
                        sharesValue = "\(shares)".replacingOccurrences(of: ".", with: "_")
                    }
                case "descripcionMov":
                    pensionTransactionDTO.description = element.stringValue.trim()
                    if let desc = pensionTransactionDTO.description?.uppercased(), !desc.isEmpty {
                        descValue = "\(desc)"
                    }
                default:
                    BSANLogger.e("PensionTransaction", "Nodo Sin Parsear! -> \(tag)")
                }

                pensionTransactionDTO.transactionNumber = "\(dateValue)-\(descValue)-\(amountValue)-\(currencyValue)-\(sharesValue)"
            }
        }

        return pensionTransactionDTO
    }
}
