import Foundation
import Fuzi

class TransferBasicDataDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TransferBasicDataDTO {
        var transferBasicDataDTO = TransferBasicDataDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "cuentaIBANPayee":
                    transferBasicDataDTO.iban = IBANDTOParser.parse(element)
                    break
                case "referencia":
                    transferBasicDataDTO.concept = element.stringValue.trim()
                    break
                case "ultimoImporte":
                    transferBasicDataDTO.transferAmount = AmountDTOParser.parse(element)
                    break
                case "nombreBAO":
                    transferBasicDataDTO.beneficiaryBAOName = element.stringValue.trim()
                    break
                case "aliasBeneficiario":
                    transferBasicDataDTO.beneficiary = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("TransferBasicDataDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return transferBasicDataDTO
    }
}
