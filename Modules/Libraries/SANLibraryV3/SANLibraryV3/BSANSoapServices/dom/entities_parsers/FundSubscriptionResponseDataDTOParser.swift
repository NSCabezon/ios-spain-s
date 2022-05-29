import Foundation
import Fuzi

class FundSubscriptionResponseDataDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> FundSubscriptionResponseDataDTO {
        var fundSubscriptionResponseDataDTO = FundSubscriptionResponseDataDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "fechaValLiq":
                    fundSubscriptionResponseDataDTO.settlementValueDate = DateFormats.safeDate(element.stringValue)
                case "ctaDomiciliacionPres":
                    fundSubscriptionResponseDataDTO.directDebtAccountContract = ContractDTOParser.parse(element)
                case "codIdioma":
                    fundSubscriptionResponseDataDTO.languageCode = element.stringValue.trim()
                case "codMonedaCuenta":
                    fundSubscriptionResponseDataDTO.accountCurrencyCode = element.stringValue.trim()
                case "importeValLiq":
                    fundSubscriptionResponseDataDTO.settlementValueAmount = AmountDTOParser.parse(element)
                default:
                    BSANLogger.e("FundSubscriptionResponseDataDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return fundSubscriptionResponseDataDTO
    }
}
