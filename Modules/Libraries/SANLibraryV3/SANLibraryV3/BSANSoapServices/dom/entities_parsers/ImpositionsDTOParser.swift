import Foundation
import Fuzi

class ImpositionsDTOParser: DTOParser {
	
	public static func parse(_ node: XMLElement) -> [ImpositionDTO] {
		var loanTransactions = [ImpositionDTO]()
        if let lista = node.firstChild(tag: "lista"){
            for element in lista.children {
                loanTransactions.append(ImpositionDTOParser.parse(element))
            }
        }
        let linkedAccount: ContractDTO?
        let linkedAccountDesc: String?
        if let child = node.firstChild(tag: "cuentaAsociada") {
            linkedAccount = ContractDTOParser.parse(child)
        } else {
            linkedAccount = nil
        }
        if let child = node.firstChild(tag: "descCuentaAsociada") {
            linkedAccountDesc = child.stringValue.trim()
        } else {
            linkedAccountDesc = nil
        }
        for i in 0 ... loanTransactions.count-1 {
            loanTransactions[i].linkedAccount = linkedAccount
            loanTransactions[i].linkedAccountDesc = linkedAccountDesc
        }
        
		return loanTransactions
	}
}

