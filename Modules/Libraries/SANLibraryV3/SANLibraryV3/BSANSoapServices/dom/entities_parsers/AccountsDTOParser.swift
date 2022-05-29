import Foundation
import Fuzi

class AccountsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [AccountDTO] {
        var accounts:  [AccountDTO] = []
        for element in node.children {
            accounts.append(AccountDTOParser.parse(element))
        }
        return accounts
    }
}
