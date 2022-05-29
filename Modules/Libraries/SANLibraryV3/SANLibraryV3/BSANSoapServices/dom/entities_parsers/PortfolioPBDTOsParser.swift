import Foundation
import Fuzi

class PortfolioPBDTOsParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> [PortfolioDTO] {
        var portfolios:  [PortfolioDTO] = []
        for element in node.children {
            let portfolio = PortfolioPBDTOParser.parse(element)
            if let portfolioId = portfolio.portfolioId, !portfolioId.isEmpty {
                portfolios.append(portfolio)
            }
        }
        return portfolios
    }
}
