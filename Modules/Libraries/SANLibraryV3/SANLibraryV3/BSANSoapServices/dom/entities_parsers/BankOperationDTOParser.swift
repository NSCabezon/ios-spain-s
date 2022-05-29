import Foundation
import Fuzi

class BankOperationDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> BankOperationDTO {
		let basicOperation = node.firstChild(tag: "OPERACION_BASICA")?.stringValue
		let bankOperation = node.firstChild(tag: "OPERACION_BANCARIA")?.stringValue
		return BankOperationDTO(basicOperation: basicOperation, bankOperation: bankOperation)
	}
}
