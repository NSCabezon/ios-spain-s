import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct PortfolioProductTransaction: GenericTransactionProtocol {
    private(set) var dto: PortfolioTransactionDTO
    
    init(dto: PortfolioTransactionDTO) {
        self.dto = dto
    }
    
    var operationDate: Date? {
        return dto.operationDate
    }
    
    var valueDate: Date? {
        return dto.valueDate
    }
    
    var description: String {
        var title = dto.description?.trim() ?? ""
        title += " " + getSharesCountWith5Decimals()
        return title.trim()
    }
    
    func getSharesCountWith5Decimals() -> String {
        let formatter = formatterForRepresentation(.sharesCount5Decimals)
        return formatter.string(for: dto.sharesCount) ?? ""
    }
    
    var amount: Amount {
        return Amount.createFromDTO(dto.amount)
    }
}
