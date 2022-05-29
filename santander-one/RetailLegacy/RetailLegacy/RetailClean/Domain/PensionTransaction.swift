import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct PensionTransaction {
    
    private(set) var pensionTransactionDTO: PensionTransactionDTO
    
    init(_ dto: PensionTransactionDTO) {
        self.pensionTransactionDTO = dto
    }

    var operationDate: Date? {
        return pensionTransactionDTO.operationDate
    }

    var description: String {
        return pensionTransactionDTO.description?.trim() ?? ""
    }

    var amount: Amount {
        return Amount.createFromDTO(pensionTransactionDTO.amount)
    }
    
    func getSharesCountWith5Decimals() -> String? {
        let formatter = formatterForRepresentation(.sharesCount5Decimals)
        return formatter.string(for: pensionTransactionDTO.sharesCount)
    }
}
