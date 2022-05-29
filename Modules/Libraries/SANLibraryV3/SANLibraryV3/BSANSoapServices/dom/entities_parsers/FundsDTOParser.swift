import Foundation
import Foundation
import Fuzi

class FundsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [FundDTO] {
        var funds:  [FundDTO] = []
        for element in node.children {
            funds.append(FundDTOParser.parse(element))
        }
        return funds
    }
}
