import Foundation
import Fuzi

class PensionTransactionsDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> [PensionTransactionDTO] {
		var accountTransactions = [PensionTransactionDTO]()
		for element in node.children {
            var pensionTransactionDTO = PensionTransactionDTOParser.parse(element)
			accountTransactions.append(pensionTransactionDTO)
		}
		return accountTransactions
	}
}
