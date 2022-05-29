import Foundation
import Fuzi

class FundTransactionDTOParser: DTOParser {

    public static func parse(_ node: XMLElement) -> FundTransactionDTO {
        var fund = FundTransactionDTO()

        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "descMovimiento":
                    fund.description = element.stringValue.trim()
                case "numParticipac":
                    fund.sharesCount = safeDecimal(element.stringValue)
                case "datosBasicos":
                    for subElement in element.children {
                        if let subElementTag = subElement.tag {
                            switch subElementTag {
                            case "codOperacionBancaria":
                                fund.bankOperationCode = subElement.stringValue.trim()
                            case "fechaSolicitud":
                                fund.applyDate = DateFormats.safeDate(subElement.stringValue)
                            case "fechaValor":
                                fund.valueDate = DateFormats.safeDate(subElement.stringValue)
                            case "impOperacion":
                                fund.amount = AmountDTOParser.parse(subElement)
                            case "numSecOperacion":
                                fund.transactionNumber = subElement.stringValue.trim()
                            case "impValorLiquidativo":
                                fund.settlementAmount = AmountDTOParser.parse(subElement)
                            default:
                                BSANLogger.e("FundTransaction", "Nodo Sin Parsear! -> \(subElementTag)")
                                break
                            }
                        }
                    }
                case "fechaOperacion":
                    fund.operationDate = DateFormats.safeDate(element.stringValue)
                default:
                    BSANLogger.e("FundTransaction", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }

        return fund
    }
}

