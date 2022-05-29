import Foundation
import Fuzi

class LoanTransactionsDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> [LoanTransactionDTO] {
		var loanTransactions = [LoanTransactionDTO]()
		for element in node.children {
			loanTransactions.append(LoanTransactionDTOParser.parse(element))
		}
		return loanTransactions
	}
}
