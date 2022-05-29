import CoreDomain
import OpenCombine

struct MockSavingTransactionBalanceDTO: Codable {
    let type: String
    let amountDTO: MockAmountResponseDTO
    let creditDebitIndicator: String
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case amountDTO = "Amount"
        case creditDebitIndicator = "CreditDebitIndicator"
    }
}

extension MockSavingTransactionBalanceDTO: SavingTransactionBalanceRepresentable {
    var amount: SavingAmountRepresentable {
        return amountDTO
    }
}
