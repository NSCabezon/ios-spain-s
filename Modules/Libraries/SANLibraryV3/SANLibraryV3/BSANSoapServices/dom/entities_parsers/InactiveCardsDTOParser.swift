import Foundation
import Fuzi

class InactiveCardsDTOParser: DTOParser {    
    public static func parse(_ node: XMLElement) -> [InactiveCardDTO] {
        var inactiveCards:  [InactiveCardDTO] = []
        for element in node.children {
            inactiveCards.append(InactiveCardDTOParser.parse(element))
        }
        return inactiveCards
    }
}
