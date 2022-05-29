import Fuzi

class CardPendingTransactionDTOListParser: DTOParser {
    public static func parse(_ node: XMLElement) -> [CardPendingTransactionDTO] {
        guard let list = node.firstChild(css: "lista") else { return [] }
        
        var cardPendingTransactionsDTO = [CardPendingTransactionDTO]()
        
        for dato in list.children {
            let parsedData = CardPendingTransactionDTOParser.parse(dato)
            if let cardNumber = parsedData.cardNumber, cardNumber.trim().count > 0 {
                cardPendingTransactionsDTO.append(parsedData)
            }
        }
        
        return cardPendingTransactionsDTO
    }
}
