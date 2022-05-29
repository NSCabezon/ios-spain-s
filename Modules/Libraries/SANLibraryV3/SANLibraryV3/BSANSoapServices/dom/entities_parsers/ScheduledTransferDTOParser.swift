import Foundation
import Fuzi

class ScheduledTransferDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TransferScheduledDTO {
        var scheduledTransferDTO = TransferScheduledDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "conceptoMP":
                    scheduledTransferDTO.concept = element.stringValue.trim()
                case "importe":
                    scheduledTransferDTO.transferAmount = AmountDTOParser.parse(element)
                case "NumOrdCabMisPag":
                    scheduledTransferDTO.numberOrderHeader = element.stringValue.trim()
                case "descTipInst":
                    scheduledTransferDTO.descTipInst = element.stringValue.trim()
                case "fechIniPerio":
                    scheduledTransferDTO.dateStartValidity = DateFormats.safeDate(element.stringValue)
                case "fechFinPerio":
                    scheduledTransferDTO.dateEndValidity = DateFormats.safeDateWithoutLimit(element.stringValue)
                case "indUrgencia":
                    scheduledTransferDTO.urgency = element.stringValue.trim()
                case "tipoTransferencia":
                    scheduledTransferDTO.typeTransfer = element.stringValue.trim()
                case "tipoSeleccion":
                    scheduledTransferDTO.typeSelection = element.stringValue.trim()
                case "tipoPeriodicidad":
                    scheduledTransferDTO.periodicalType = PeriodicalTypeTransferDTO.findBy(type: element.firstChild(tag: "CODIGO_ALFANUM_3")?.stringValue)
                    break;
                default:
                    BSANLogger.e("ScheduledTransferDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return scheduledTransferDTO
    }
}
