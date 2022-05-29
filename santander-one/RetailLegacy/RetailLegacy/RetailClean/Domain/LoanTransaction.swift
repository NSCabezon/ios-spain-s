import SANLegacyLibrary
import Foundation

struct LoanTransaction {

    private(set) var loanTransactionDTO: LoanTransactionDTO

    init(_ dto: LoanTransactionDTO) {
        self.loanTransactionDTO = dto
    }

    var operationDate: Date? {
        return loanTransactionDTO.operationDate
    }
    
    var valueDate: Date? {
        return loanTransactionDTO.valueDate
    }

    var description: String {
        return loanTransactionDTO.description?.trim() ?? ""
    }

    var amount: Amount {
        return Amount.createFromDTO(loanTransactionDTO.amount)
    }
}
