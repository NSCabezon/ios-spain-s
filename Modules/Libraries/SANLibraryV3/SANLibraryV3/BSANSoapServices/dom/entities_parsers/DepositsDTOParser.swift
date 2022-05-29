import Foundation
import Fuzi

class DepositsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [DepositDTO] {
        var deposits:  [DepositDTO] = []
        for element in node.children {
            deposits.append(DepositDTOParser.parse(element))
        }
        return deposits
    }
}
