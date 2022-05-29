import Foundation
import Fuzi

class AccountDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> AccountDTO {
        var accountDTO = AccountDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "comunes":
                    let comunesDTO: ComunesDTO = ComunesDTOParser.parse(element)
                    accountDTO.contract = comunesDTO.contract
                    accountDTO.alias = comunesDTO.alias
                    accountDTO.contractDescription = comunesDTO.descontrato
                    accountDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: comunesDTO.descTipoInterv)
                    accountDTO.ownershipType = comunesDTO.tipoInterv
                    accountDTO.indVisibleAlias = comunesDTO.indVisibleAlias
                    accountDTO.productSubtypeDTO = comunesDTO.productSubtype
                    break
                case "impSaldoActual":
                    accountDTO.currentBalance = AmountDTOParser.parse(element)
                    break
                case "importeDispAut":
                    accountDTO.availableAutAmount = AmountDTOParser.parse(element)
                    break
                case "importeDispSinAut":
                    accountDTO.availableNoAutAmount = AmountDTOParser.parse(element)
                    break
                case "importeLimite":
                    accountDTO.limitAmount = AmountDTOParser.parse(element)
                    break
                case "IBAN":
                    accountDTO.iban = IBANDTO(ibanString: element.stringValue.trim())
                    break
                case "contratoIDViejo":
                    accountDTO.oldContract = ContractDTOParser.parse(element)
                    break
                case "titular":
                    accountDTO.client = ClientDTOParser.parse(element)
                    break
                case "tipoSituacionCto":
                    accountDTO.tipoSituacionCto = element.stringValue.trim()
                    break
                case "impSaldoActualContravalor":
                    accountDTO.countervalueCurrentBalanceAmount = AmountDTOParser.parse(element)
                    break
                case "importeDispAutContravalor":
                    accountDTO.countervalueAvailableAutAmount = AmountDTOParser.parse(element)
                    break
                case "importeDispSinAutContravalor":
                    accountDTO.countervalueAvailableNoAutAmount = AmountDTOParser.parse(element)
                    break
                case "importeLimiteContravalor":
                    accountDTO.countervalueLimitAmount = AmountDTOParser.parse(element)
                    break
                case "descCuentaContratoIDViejo": //Deprecated
                    break
                default:
                    BSANLogger.e("AccountDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return accountDTO
    }
}
