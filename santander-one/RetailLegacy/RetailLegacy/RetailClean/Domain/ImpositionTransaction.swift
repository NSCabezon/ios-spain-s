import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct ImpositionTransaction: GenericTransactionProtocol {
    private let dto: ImpositionTransactionDTO
    
    init(dto: ImpositionTransactionDTO) {
        self.dto = dto
    }
    
    var description: String {
        return dto.description?.trim() ?? ""
    }
    
    var operationDate: Date? {
        return dto.operationDate
    }
    
    var valueDate: Date? {
        return dto.valueDate
    }
    
    var amount: Amount {
        return Amount.createFromDTO(dto.amount)
    }
    
    func getSharesCountWith5Decimals() -> String? {
        let formatter = formatterForRepresentation(.sharesCount5Decimals)
        return formatter.string(for: dto.amount)
    }
}
