import Foundation
import Fuzi

final class PayeeDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> PayeeDTO {
        var payeeDTO = PayeeDTO()
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "actuante":
                    let idActuantePayeeDTO = IdActuantePayeeDTOParser.parse(element)
                    payeeDTO.actingNumber = idActuantePayeeDTO.actingNumber
                    payeeDTO.actingTypeCode = idActuantePayeeDTO.actingTypeCode
                case "codigo":
                    payeeDTO.codPayee = element.stringValue.trim()
                case "cuenta":
                    payeeDTO.iban = IBANDTOParser.parse(element)
                case "referencia":
                    payeeDTO.concept = element.stringValue.trim()
                case "importe":
                    payeeDTO.transferAmount = AmountDTOParser.parse(element)
                case "nombreBeneficiario":
                    payeeDTO.beneficiaryBAOName = element.stringValue.trim()
                case "alias":
                    payeeDTO.beneficiary = element.stringValue.trim()
                case "cuentaDestino":
                    payeeDTO.destinationAccount = element.stringValue.trim()
                case "tipoCuenta":
                    payeeDTO.accountType = element.stringValue.trim()
                case "tipoDestinatario":
                    payeeDTO.recipientType = element.stringValue.trim()
                default:
                    BSANLogger.e("PayeeDTOParser", "Nodo Sin Parsear! -> \(tag)")
                }
            }
        }
        return payeeDTO
    }
}
