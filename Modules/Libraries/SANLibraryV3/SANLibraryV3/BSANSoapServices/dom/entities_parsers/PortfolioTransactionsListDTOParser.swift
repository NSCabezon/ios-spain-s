import Foundation
import Fuzi

class PortfolioTransactionsListDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> PortfolioTransactionsListDTO {
        var portfolioTransactionsListDTO = PortfolioTransactionsListDTO()
        
        if node.children(tag: "dato").count == 0{
            return portfolioTransactionsListDTO
        }
        
        var transactionDTOs: [PortfolioTransactionDTO] = []
        
        for i in 0 ... node.children(tag: "dato").count-1{
            let childElement = node.children(tag: "dato")[i]
            let transaction = PortfolioTransactionDTOParser.parse(childElement)
            transactionDTOs.append(transaction)
        }
        portfolioTransactionsListDTO.transactionDTOs = transactionDTOs
        return portfolioTransactionsListDTO
    }
}
