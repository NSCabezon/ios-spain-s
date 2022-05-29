import CoreDomain
import OpenCombine

struct MockSavingAccountBalanceDTO: Codable {
    let creditLinesDTO: [MockSavingAccountBalanceCreditLineDTO]?
    
    enum CodingKeys: String, CodingKey {
        case creditLinesDTO = "CreditLine"
    }
}
extension MockSavingAccountBalanceDTO: SavingAccountBalanceRepresentable {
    var creditLines: [SavingAccountBalanceCreditLineRepresentable]? {
        return creditLinesDTO
    }
}
