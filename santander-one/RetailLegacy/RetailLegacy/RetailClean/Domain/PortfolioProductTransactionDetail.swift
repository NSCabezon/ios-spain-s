import SANLegacyLibrary
import Foundation

struct PortfolioProductTransactionDetail {
    private let dto: PortfolioTransactionDetailDTO
    
    init(dto: PortfolioTransactionDetailDTO) {
        self.dto = dto
    }
    
    var expensesAmount: Amount? {
        guard let amount = dto.expensesAmount else {
            return nil
        }
        return Amount.createFromDTO(amount)
    }

    var valueDate: Date? {
        return dto.valueDate
    }
}
