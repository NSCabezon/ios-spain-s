import Foundation
import Fuzi

class FundTransactionsDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> [FundTransactionDTO] {
		var fundTransactions = [FundTransactionDTO]()
		for element in node.children {
			fundTransactions.append(FundTransactionDTOParser.parse(element))
		}
		return fundTransactions
	}
}
