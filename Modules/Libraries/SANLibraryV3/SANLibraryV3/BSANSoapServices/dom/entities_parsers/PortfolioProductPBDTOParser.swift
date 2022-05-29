import Foundation
import Fuzi

class PortfolioProductPBDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PortfolioProductDTO {
        var portfolioProductPBDTO = PortfolioProductDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "descDetalleCartera":
                    portfolioProductPBDTO.alias = element.stringValue.trim()
                case "idCartera":
                    portfolioProductPBDTO.portfolioId = element.stringValue.trim()
                case "cuentaDeValores":
                    portfolioProductPBDTO.stockAccountData = AccountDataDTOParser.parse(element)
                case "descCuenta":
                    portfolioProductPBDTO.accountDesc = element.stringValue.trim()
                case "nombreValor":
                    portfolioProductPBDTO.valueName = element.stringValue.trim()
                case "valorCotizacion":
                    portfolioProductPBDTO.priceValue = DTOParser.safeDecimal(element.stringValue.trim())
                case "tipoDeActivo":
                    portfolioProductPBDTO.activeType = element.stringValue.trim()
                case "impContravalor":
                    portfolioProductPBDTO.countervalueAmount = AmountDTOParser.parse(element)
                case "impContravalorMoneda":
                    portfolioProductPBDTO.countervalueCoinAmount = AmountDTOParser.parse(element)
                case "impUltSaldoConsolidado":
                    portfolioProductPBDTO.impUltSaldoConsolidado = AmountDTOParser.parse(element)
                case "impEfectivo":
                    portfolioProductPBDTO.cashAmount = AmountDTOParser.parse(element)
                case "impVariacion":
                    portfolioProductPBDTO.variationAmount = AmountDTOParser.parse(element)
                case "impValorLiquidativo":
                    portfolioProductPBDTO.netAssetValue = AmountDTOParser.parse(element)
                case "indTipoCartera":
                    portfolioProductPBDTO.portfolioTypeInd = element.stringValue.trim()
                case "bloqueCartera":
                    portfolioProductPBDTO.portfolioBlock = element.stringValue.trim()
                case "descBloqueCartera":
                    portfolioProductPBDTO.portfolioBlockDesc = element.stringValue.trim()
                case "descTipoCartera":
                    portfolioProductPBDTO.portfolioTypeDesc = element.stringValue.trim()
                default:
                    BSANLogger.e("PortfolioProductPBDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return portfolioProductPBDTO
    }
}
