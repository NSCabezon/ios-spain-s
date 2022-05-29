import Foundation
import Fuzi

class TransferNationalDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TransferNationalDTO {
        var transferNationalDTO = TransferNationalDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaEmisionTransf":
                    transferNationalDTO.issueDate = DateFormats.safeDate(element.stringValue)
                    break
                case "impTransferencia":
                    transferNationalDTO.transferAmount = AmountDTOParser.parse(element)
                    break
                case "impComision":
                    transferNationalDTO.bankChargeAmount = AmountDTOParser.parse(element)
                    break
                case "impGastos":
                    transferNationalDTO.expensesAmount = AmountDTOParser.parse(element)
                    break
                case "impLiquido":
                    transferNationalDTO.netAmount = AmountDTOParser.parse(element)
                    break
                case "nombreOrdenante":
                    transferNationalDTO.payerName = element.stringValue.trim()
                    break
                case "descCuentaAbono":
                    transferNationalDTO.originAccountDescription = element.stringValue.trim()
                    break
                case "descCuentaCargo":
                    transferNationalDTO.destinationAccountDescription = element.stringValue.trim()
                    break               
                default:
                    BSANLogger.e("TransferNationalDTOParser", "Nodo Sin Parsear! -> \(tag)")
                }
            }
        }
        
        return transferNationalDTO
    }
}
