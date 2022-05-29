import Foundation
import Fuzi

class ServiceOrderDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> ContractDTO {
        var contractDTO = ContractDTO()
        
        contractDTO.product = node.firstChild(tag:"PRODUCTO")?.stringValue.trim()
        contractDTO.contractNumber = node.firstChild(tag:"NUMERO_DE_ORDEN")?.stringValue.trim()
        if let bankNode = node.firstChild(tag:"CENTRO"){
            contractDTO.bankCode = bankNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
            contractDTO.branchCode = bankNode.firstChild(tag:"CENTRO")?.stringValue.trim()
        }
        
        return contractDTO
    }
}
