//

import SANLegacyLibrary
import CoreFoundationLib

class AccountDetail: Account {
    
    private let accountDetailDTO: AccountDetailDTO
    
    static func create(_ dto: AccountDTO, detailDTO: AccountDetailDTO) -> AccountDetail {
        return AccountDetail(dto, detailDTO: detailDTO)
    }

    init(_ dto: AccountDTO, detailDTO: AccountDetailDTO) {
        self.accountDetailDTO = detailDTO
        super.init(AccountEntity(dto))
    }

    var getHolder: String? {
        guard let holder = accountDetailDTO.holder else { return nil}
        return holder
    }
    
    var getWithholdingAmount: String? {
        guard let withholdingAmount = accountDetailDTO.withholdingAmount else { return nil }
        let amount = Amount.createFromDTO(withholdingAmount)
        return amount.getFormattedAmountUI()
    }
}
