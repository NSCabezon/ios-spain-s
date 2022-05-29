import CoreDomain
import OpenCombine

struct MockBankSavingTransactionCodeDTO: Codable {
    let code: String
    let subCode: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case subCode = "SubCode"
    }
}

extension MockBankSavingTransactionCodeDTO: BankSavingTransactionCodeRepresentable {}
