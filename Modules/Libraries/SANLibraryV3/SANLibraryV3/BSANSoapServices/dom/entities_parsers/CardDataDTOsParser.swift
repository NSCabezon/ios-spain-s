import Foundation
import Fuzi

class CardDataDTOsParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [CardDataDTO] {
        var cardsData:  [CardDataDTO] = []
        for element in node.children {
            cardsData.append(CardDataDTOParser.parse(element))
        }
        return cardsData
    }
}
