import SANLegacyLibrary
import Foundation
import CoreFoundationLib

struct FundTransaction {

    private(set) var fundTransactionDTO: FundTransactionDTO

    init(_ dto: FundTransactionDTO) {
        self.fundTransactionDTO = dto
    }

    var operationDate: Date? {
        return fundTransactionDTO.operationDate
    }
    
    var valueDate: Date? {
        return fundTransactionDTO.valueDate
    }

    var description: String {
        var title = fundTransactionDTO.description?.trim() ?? ""
        title += " " + getSharesCountWith5Decimals()
        return title.trim()
    }

    func getSharesCountWith5Decimals() -> String {
        let formatter = formatterForRepresentation(.sharesCount5Decimals)
        return formatter.string(for: fundTransactionDTO.sharesCount) ?? ""
    }

    var amount: Amount {
        return Amount.createFromDTO(fundTransactionDTO.amount)
    }
}
