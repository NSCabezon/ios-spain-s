import Foundation
import Fuzi

class InsurancePolicyDTOParser: DTOParser  {
    
    public static func parse(_ node: XMLElement) -> InsurancePolicyDTO {
        var insurancePolicyDTO = InsurancePolicyDTO()
        insurancePolicyDTO.policyNumber = node.firstChild(tag:"NUMERO_POLIZA_SEGURO")?.stringValue.trim()
        insurancePolicyDTO.policyCertNumber = node.firstChild(tag:"NUMERO_CERTIFICADO_POLIZA")?.stringValue.trim()
        if let insurancesModeNode = node.firstChild(tag:"MODALIDAD_DE_SEGUROS"){
            insurancePolicyDTO.productCod = insurancesModeNode.firstChild(tag:"COD_PRODUCTO")?.stringValue.trim()
            if let insurancesBranchNode = insurancesModeNode.firstChild(tag:"RAMO_DE_SEGUROS"){
                insurancePolicyDTO.codCompanySeg = insurancesBranchNode.firstChild(tag:"COD_COMPANIA_SEG")?.stringValue.trim()
                 insurancePolicyDTO.codRamo = insurancesBranchNode.firstChild(tag:"COD_RAMO")?.stringValue.trim()
            }
        }
        return insurancePolicyDTO
    }
}
