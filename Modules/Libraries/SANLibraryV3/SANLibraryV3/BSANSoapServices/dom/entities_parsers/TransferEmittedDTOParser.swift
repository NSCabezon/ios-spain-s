import Foundation
import Fuzi

class TransferEmittedDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TransferEmittedDTO {
        var transferEmittedDTO = TransferEmittedDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaEjecucion":
                    transferEmittedDTO.executedDate = DateFormats.safeDate(element.stringValue)
                case "nombreBeneficiario":
                    transferEmittedDTO.beneficiary = element.stringValue.trim()
                case "concepto":
                    transferEmittedDTO.concept = element.stringValue.trim()
                case "importe":
                    transferEmittedDTO.amount = AmountDTOParser.parse(element)
                case "pais":
                    transferEmittedDTO.countryCode = element.stringValue.trim()
                case "ordenServicio":
                    transferEmittedDTO.serviceOrder = ServiceOrderDTOParser.parse(element)
                case "numeroTransferencia":
                    transferEmittedDTO.transferNumber = element.stringValue.trim()
                case "codigoAplicacion":
                    transferEmittedDTO.aplicationCode = element.stringValue.trim()
                case "tipoTransferencia":
                    transferEmittedDTO.transferType = element.stringValue.trim()
                case "nombrePais":
                    transferEmittedDTO.countryName = element.stringValue.trim()
                default:
                    BSANLogger.e("TransferEmittedDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return transferEmittedDTO
    }
}
