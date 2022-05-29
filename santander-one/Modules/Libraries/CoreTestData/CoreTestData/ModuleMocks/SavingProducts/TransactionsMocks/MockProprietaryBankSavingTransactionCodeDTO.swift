import CoreDomain
import OpenCombine

struct MockProprietaryBankSavingTransactionCodeDTO: Codable {
    let code: String
    let issuer: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "Code"
        case issuer = "Issuer"
    }
}

extension MockProprietaryBankSavingTransactionCodeDTO: ProprietaryBankSavingTransactionCodeRepresentable {}
