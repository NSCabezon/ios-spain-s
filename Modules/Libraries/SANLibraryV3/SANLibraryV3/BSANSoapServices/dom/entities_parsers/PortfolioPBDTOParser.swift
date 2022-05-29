import Foundation
import Fuzi

class PortfolioPBDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PortfolioDTO {
        var portfolioDTO = PortfolioDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "contrato":
                    portfolioDTO.contract = ContractDTOParser.parse(element)
                    break
                case "cuentaDeValores":
                    portfolioDTO.stockAccountData = AccountDataDTOParser.parse(element)
                    break
                case "descDetalleCartera":
                    portfolioDTO.alias = element.stringValue.trim()
                    break
                case "nombreTitular":
                    portfolioDTO.holderName = element.stringValue.trim()
                    break
                case "idCartera":
                    portfolioDTO.portfolioId = element.stringValue.trim()
                    break
                case "tipoCartera":
                    portfolioDTO.portfolioType = element.stringValue.trim()
                    break
                case "impUltSaldoConsolidado":
                    portfolioDTO.consolidatedBalance = AmountDTOParser.parse(element)
                    break
                case "descTipoIntervencion":
                    portfolioDTO.ownershipTypeDesc = OwnershipTypeDesc.findBy(type: element.stringValue.trim())
                    break
                case "indDisponibilidad":
                    portfolioDTO.availabilityInd = element.stringValue.trim()
                    break
                case "indTipoCartera":
                    portfolioDTO.portfolioTypeInd = element.stringValue.trim()
                    break
                case "descTipoCartera":
                    portfolioDTO.portfolioTypeDesc = element.stringValue.trim()
                    break
                case "descCuenta":
                    portfolioDTO.accountDesc = element.stringValue.trim()
                    break
                default:
                    BSANLogger.e("PortfolioPBDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        
        return portfolioDTO
    }
}
