import Foundation
import Fuzi

class DirectMoneyDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> DirectMoneyDTO {
        var directMoneyDTO = DirectMoneyDTO()
        
        if let datosDisponible = node.firstChild(tag: "datosDisponible"){
            if let cuentaDeIngreso = datosDisponible.firstChild(tag: "cuentaDeIngreso"){
                let accountDataDTO = AccountDataDTOParser.parse(cuentaDeIngreso)
                directMoneyDTO.linkedAccountCheckDigits = accountDataDTO.checkDigits
                directMoneyDTO.linkedAccountBank = accountDataDTO.bankCode
                directMoneyDTO.linkedAccountBranch = accountDataDTO.branchCode
                directMoneyDTO.linkedAccountNumber = accountDataDTO.accountNumber
            }
            
            if let titular = datosDisponible.firstChild(tag: "titular"){
                directMoneyDTO.holder = titular.stringValue.trim()
            }
            
            if let importeSalDisponible = datosDisponible.firstChild(tag: "importeSalDisponible"){
                directMoneyDTO.availableAmount = AmountDTOParser.parse(importeSalDisponible)
            }
            
            if let descTipoTarjeta = datosDisponible.firstChild(tag: "descTipoTarjeta"){
                directMoneyDTO.cardTypeDescription = descTipoTarjeta.stringValue.trim()
            }
            
            if let descImporteMinimo = datosDisponible.firstChild(tag: "descImporteMinimo"){
                directMoneyDTO.minAmountDescription = descImporteMinimo.stringValue.trim()
            }
            
            if let numeroTarj = node.firstChild(tag: "numeroTarj"){
                directMoneyDTO.cardNumber = numeroTarj.stringValue.trim()
            }
            
            if let descTarjeta = node.firstChild(tag: "descTarjeta"){
                directMoneyDTO.cardDescription = descTarjeta.stringValue.trim()
            }
            
            if let descSituacionContratoTarjeta = node.firstChild(tag: "descSituacionContratoTarjeta"){
                directMoneyDTO.cardContractStatusDesc = descSituacionContratoTarjeta.stringValue.trim()
            }
        }
                
        return directMoneyDTO
    }
}
