import Foundation
import Fuzi

class AccountTransactionDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> AccountTransactionDTO {
		var accountTransaction = AccountTransactionDTO()
		
		for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaOperacion":
                    accountTransaction.operationDate = DateFormats.safeDate(element.stringValue)
                case "fechaValor":
                    accountTransaction.valueDate = DateFormats.safeDate(element.stringValue)
                case "importe":
                    accountTransaction.amount = AmountDTOParser.parse(element)
                case "tipoMovimiento":
                    accountTransaction.transactionType = element.stringValue.trim()
                case "importeSaldo":
                    accountTransaction.balance = AmountDTOParser.parse(element)
                case "diaMovimiento":
                    accountTransaction.transactionDay = element.stringValue.trim()
                case "fechaAnotacion":
                    accountTransaction.annotationDate = DateFormats.safeDate(element.stringValue)
                case "numeroDGO":
                    accountTransaction.dgoNumber = DGONumberDTOParser.parse(element)
                case "descripcion":
                    accountTransaction.description = element.stringValue.trim()
                case "numeroMovimiento":
                    accountTransaction.transactionNumber = element.stringValue.trim()
                case "indicadorPdf":
                    accountTransaction.pdfIndicator = element.stringValue.trim()
                default:
                    BSANLogger.e("PortfolioPBDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
		
		return accountTransaction
	}
}
