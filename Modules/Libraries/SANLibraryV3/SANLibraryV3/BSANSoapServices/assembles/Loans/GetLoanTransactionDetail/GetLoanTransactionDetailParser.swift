import Foundation
import Fuzi

public class GetLoanTransactionDetailParser : BSANParser <GetLoanTransactionDetailResponse, GetLoanTransactionDetailHandler> {
    override func setResponseData(){
        response.loanTransactionDetailDTO = handler.loanTransactionDetailDTO
    }
}

public class GetLoanTransactionDetailHandler: BSANHandler {
    
    var loanTransactionDetailDTO = LoanTransactionDetailDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "impCuota":
            loanTransactionDetailDTO.feeAmount = AmountDTOParser.parse(element)
        case "capital":
            loanTransactionDetailDTO.capital = AmountDTOParser.parse(element)
        case "impIntereses":
            loanTransactionDetailDTO.interestAmount = AmountDTOParser.parse(element)
        case "capitalPendiente":
            loanTransactionDetailDTO.pendingAmount = AmountDTOParser.parse(element)
        default:
            BSANLogger.e("FundDetailHandler", "Nodo Sin Parsear! -> \(tag)")
        }
    }
}
