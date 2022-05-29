import Foundation
import Fuzi

class LoanDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> LoanDTO {
        var loanDTO = LoanDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    loanDTO.contract = comunesDTO.contract
                    loanDTO.alias = comunesDTO.alias
                    loanDTO.contractDescription = comunesDTO.descontrato
                    loanDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    loanDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    break
                case "impSaldoDispuesto":
                    loanDTO.currentBalance = AmountDTOParser.parse(element)
                    break
                case "impDisponible":
                    loanDTO.availableAmount = AmountDTOParser.parse(element)
                    break
                case "impDisponibleContravalor":
                    loanDTO.counterValueAvailableBalanceAmount = AmountDTOParser.parse(element)
                    break
                case "importeSalDisptoContravalor", "impSaldoDispuestoContravalor":
                    loanDTO.counterValueCurrentBalanceAmount = AmountDTOParser.parse(element)
                    break
                case "descSituacionContrato":
                    loanDTO.contractStatusDesc = element.stringValue.trim()
                default:
                    BSANLogger.e("LoanDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return loanDTO
    }
    
    
    
}
