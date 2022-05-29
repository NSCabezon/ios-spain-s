import Foundation
import Fuzi

class DGONumberDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> DGONumberDTO {
		var dgoNumberDTO = DGONumberDTO()
		
		if let bankNode = node.firstChild(tag:"CENTRO"){
			dgoNumberDTO.company = bankNode.firstChild(tag:"EMPRESA")?.stringValue.trim()
			dgoNumberDTO.center = bankNode.firstChild(tag:"CENTRO")?.stringValue.trim()
		}
		
		dgoNumberDTO.terminalCode = node.firstChild(tag:"CODIGO_TERMINAL_DGO")?.stringValue.trim()
		dgoNumberDTO.number = node.firstChild(tag:"NUMERO_DGO")?.stringValue.trim()
		
		return dgoNumberDTO
	}
}
