import Foundation
import Fuzi

class LoansDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [LoanDTO] {
        var loans:  [LoanDTO] = []
        for element in node.children {
            loans.append(LoanDTOParser.parse(element))
        }
        return loans
    }
}
