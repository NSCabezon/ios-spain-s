import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct AccountTransaction: CustomStringConvertible {
    
    var operationDate: Date? {
        return dto.operationDate
    }
    var valueDate: Date? {
        return dto.valueDate
    }
    var amount: Amount {
        return Amount.createFromDTO(dto.amount)
    }
    var balance: Amount {
        return Amount.createFromDTO(dto.balance)
    }
    var description: String {
        return dto.description?.trim() ?? ""
    }
    
    var pdfIndicator: Bool {
        return dto.pdfIndicator == "2"
    }
    
    private(set) var dto: AccountTransactionDTO
    let fundableType: AccountEasyPayFundableType
    
    init(entity: AccountTransactionEntity, fundableType: AccountEasyPayFundableType = .notAllowed) {
        self.init(entity.dto, fundableType: fundableType)
    }
    
    init(_ dto: AccountTransactionDTO, fundableType: AccountEasyPayFundableType = .notAllowed) {
        self.dto = dto
        self.fundableType = fundableType
    }

}
