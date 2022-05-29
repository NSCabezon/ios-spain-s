import Foundation
import Fuzi

class StockAccountsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [StockAccountDTO] {
        var stockAccounts:  [StockAccountDTO] = []
        for element in node.children {
            stockAccounts.append(StockAccountDTOParser.parse(element))
        }
        return stockAccounts
    }
}
