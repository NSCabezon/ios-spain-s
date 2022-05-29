import Foundation
import Fuzi

class ImpositionDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ImpositionDTO {
        var loan = ImpositionDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaApertura":
                    loan.openingDate = DateFormats.safeDate(element.stringValue)
                case "fechaVencimiento":
                    loan.dueDate = DateFormats.safeDate(element.stringValue)
                case "TAE":
                    loan.TAE = element.stringValue
                case "importeLiq":
                    loan.settlementAmount = AmountDTOParser.parse(element)
                case "descIndCapitalizIntereses":
                    loan.interestCapitalizationIndDesc = element.stringValue
                case "descIndRenovacion":
                    loan.renovationIndDesc = element.stringValue
                case "subcontratoImposicion":
                    loan.impositionSubContract = SubContractDTOParser.parse(element)
                default:
                    BSANLogger.e("ImpositionDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return loan
    }
}
