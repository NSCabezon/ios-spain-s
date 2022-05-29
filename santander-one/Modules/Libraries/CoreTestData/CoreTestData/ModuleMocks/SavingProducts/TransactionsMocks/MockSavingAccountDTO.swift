import CoreDomain
import OpenCombine

struct MockSavingAccountDTO: Codable {
    let balancesDTO: [MockSavingAccountBalanceDTO]?
    
    enum CodingKeys: String, CodingKey {
        case balancesDTO = "Balance"
    }
}

extension MockSavingAccountDTO: SavingAccountRepresentable {
    var balances: [SavingAccountBalanceRepresentable]? {
        return balancesDTO
    }
}
