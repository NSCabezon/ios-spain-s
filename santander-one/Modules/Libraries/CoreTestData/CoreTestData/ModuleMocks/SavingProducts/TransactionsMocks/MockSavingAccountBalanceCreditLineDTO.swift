import CoreDomain
import OpenCombine

struct MockSavingAccountBalanceCreditLineDTO: Codable {
    let included: String
    let type: String
    let amountDTO: MockAmountResponseDTO
    
    enum CodingKeys: String, CodingKey {
        case included = "Included"
        case type = "Type"
        case amountDTO = "Amount"
    }
}
extension MockSavingAccountBalanceCreditLineDTO: SavingAccountBalanceCreditLineRepresentable {
    var amount: AmountRepresentable {
        return amountDTO
    }
}
