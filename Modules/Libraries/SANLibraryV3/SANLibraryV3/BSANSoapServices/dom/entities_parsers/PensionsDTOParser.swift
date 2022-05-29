import Foundation
import Fuzi

class PensionsDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [PensionDTO] {
        var pensions:  [PensionDTO] = []
        for element in node.children {
            pensions.append(PensionDTOParser.parse(element))
        }
        return pensions
    }
}
