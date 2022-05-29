import Foundation
import Fuzi

class LoanTransactionDTOParser: DTOParser {

    public static func parse(_ node: XMLElement) -> LoanTransactionDTO {
        var loan = LoanTransactionDTO()

        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "saldo":
                    loan.balance = AmountDTOParser.parse(element)
                case "descMovimiento":
                    loan.description = element.stringValue.trim()
                case "datosMovimiento":
                    for subElement in element.children {
                        if let subElementTag = subElement.tag {
                            switch subElementTag {
                            case "operacionDGO":
                                loan.dgoNumber = DGONumberDTOParser.parse(subElement)
                            case "impMovimiento":
                                loan.amount = AmountDTOParser.parse(subElement)
                            case "operacionBancaria":
                                loan.bankOperation = BankOperationDTOParser.parse(subElement)
                            case "numSecMovimiento":
                                loan.transactionNumber = subElement.stringValue.trim()
                            case "datosAux":
                                for subSubElement in subElement.children {
                                    if let subSubElementTag = subSubElement.tag {
                                        switch subSubElement.tag! {
                                        case "fechaOperacion":
                                            loan.operationDate = DateFormats.safeDate(subSubElement.stringValue)
                                        case "fechaValor":
                                            loan.valueDate = DateFormats.safeDate(subSubElement.stringValue)
                                        default:
                                            BSANLogger.e("LoanTransactionDTOParser", "Nodo Sin Parsear! -> \(subSubElementTag)")
                                            break
                                        }
                                    }
                                }
                            default:
                                BSANLogger.e("LoanTransactionDTOParser", "Nodo Sin Parsear! -> \(subElementTag)")
                                break
                            }
                        }
                    }
                default:
                    BSANLogger.e("LoanTransactionDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }

        return loan
    }
}


