import Fuzi

public class GetCardPendingTransactionsParser: BSANParser<GetCardPendingTransactionsResponse, GetCardPendingTransactionsHandler> {
    override func setResponseData() {
        response.cardPendingTransactionsListDTO = CardPendingTransactionsListDTO(cardPendingTransactionDTOS: handler.cardPendingTransactionDTOS, pagination: handler.pagination)
    }
}

public class GetCardPendingTransactionsHandler: BSANHandler {
    var cardPendingTransactionDTOS = [CardPendingTransactionDTO]()
    var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        pagination = PaginationParser.parse(result)
        cardPendingTransactionDTOS = CardPendingTransactionDTOListParser.parse(result)
    }
}
