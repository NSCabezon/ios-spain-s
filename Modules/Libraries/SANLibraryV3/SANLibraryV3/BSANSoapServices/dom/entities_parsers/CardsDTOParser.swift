import Foundation
import Fuzi

class CardsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [CardDTO] {
        var cards:  [CardDTO] = []
        for element in node.children {
            cards.append(CardDTOParser.parse(element))
        }
        return cards
    }
}
