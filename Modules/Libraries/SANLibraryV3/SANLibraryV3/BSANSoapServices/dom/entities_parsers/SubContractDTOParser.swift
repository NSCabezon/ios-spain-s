import Foundation
import Fuzi

class SubContractDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> SubContractDTO {
		var subcontractDTO = SubContractDTO()
		
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "CONTRATO":
                    subcontractDTO.contract = ContractDTOParser.parse(element)
                case "SUBCONTRATO":
                    subcontractDTO.subcontractString = element.stringValue
                default:
                    BSANLogger.e("ReferenceStandardDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
		}
		
		return subcontractDTO
	}
}

