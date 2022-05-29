import Foundation
import Fuzi

class PersonDataDTOsParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [PersonDataDTO] {
        var personDataDTOs:  [PersonDataDTO] = []
        for element in node.children {
            personDataDTOs.append(PersonDataDTOParser.parse(element))
        }
        return personDataDTOs
    }
}
