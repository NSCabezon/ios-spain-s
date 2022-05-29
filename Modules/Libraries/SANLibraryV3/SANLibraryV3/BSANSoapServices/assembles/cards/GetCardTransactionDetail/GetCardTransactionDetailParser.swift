import Foundation
import Fuzi

public class GetCardTransactionDetailParser : BSANParser <GetCardTransactionDetailResponse, GetCardTransactionDetailHandler> {
    override func setResponseData(){
        response.cardTransactionDetailDTO = handler.cardTransactionDetailDTO
    }
}

public class GetCardTransactionDetailHandler: BSANHandler {
    
    var cardTransactionDetailDTO = CardTransactionDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {

        case "horaMovim":
            cardTransactionDetailDTO.transactionTime = element.stringValue.trim()
        case "importeMovto":
            cardTransactionDetailDTO.detailAmount = AmountDTOParser.parse(element)
        case "importeEur":
            cardTransactionDetailDTO.eurAmount = AmountDTOParser.parse(element)
        case "impComision":
            cardTransactionDetailDTO.bankCharge = AmountDTOParser.parse(element)
        case "fechaLiquidacion":
            cardTransactionDetailDTO.liquidationDate = DateFormats.safeDate(element.stringValue)
        case "indLiquidado":
            cardTransactionDetailDTO.liquidated = DTOParser.safeBoolean(element.stringValue)
        case "numTarjeta":
            cardTransactionDetailDTO.numTarjeta = element.stringValue.trim()
        case "descMovimiento":
            cardTransactionDetailDTO.description = element.stringValue.trim()
        case "codOpera":
            cardTransactionDetailDTO.bankOperation = BankOperationDTOParser.parse(element)
        default:
            BSANLogger.e("GetCardTransactionDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
