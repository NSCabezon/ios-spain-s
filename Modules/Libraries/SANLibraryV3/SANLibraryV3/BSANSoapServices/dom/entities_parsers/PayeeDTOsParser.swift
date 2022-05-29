import Foundation
import Fuzi

class PayeeDTOsParser: DTOParser {
    public static func parse(_ node: XMLElement) -> [PayeeDTO] {
        var payeeDTOs:  [PayeeDTO] = []
        for element in node.children {
            payeeDTOs.append(PayeeDTOParser.parse(element))
        }
        return payeeDTOs
    }
}
