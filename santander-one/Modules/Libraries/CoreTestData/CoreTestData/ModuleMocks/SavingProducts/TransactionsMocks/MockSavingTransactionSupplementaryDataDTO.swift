import CoreDomain
import OpenCombine

struct MockSavingTransactionSupplementaryDataDTO: Codable {
    let shortDescription: String
    
    enum CodingKeys: String, CodingKey {
        case shortDescription = "ShortDescription"
    }
}

extension MockSavingTransactionSupplementaryDataDTO: SavingTransactionSupplementaryDataRepresentable {}
