import Foundation
import Fuzi

class InsurancesDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [InsuranceDTO] {
        var insurances:  [InsuranceDTO] = []
        for element in node.children {
            insurances.append(InsuranceDTOParser.parse(element))
        }
        return insurances
    }
}
