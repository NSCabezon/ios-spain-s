import SANLegacyLibrary
import PFM
import CoreFoundationLib

struct AccountPfm {
    private let accountDto: AccountDTO
    
    init(account: AccountEntity) {
        self.accountDto = account.dto
    }
    
    var ibanString: String? {
        guard let countryCode = accountDto.iban?.countryCode, let checkDigits = accountDto.iban?.checkDigits, let codBban = accountDto.iban?.codBban else {
            return nil
        }
        return "\(countryCode)\(checkDigits)\(codBban)"
    }
    
    var bankCode: String? {
        return accountDto.contract?.bankCode
    }
    
    var branchCode: String? {
        return accountDto.contract?.branchCode
    }
    
    var product: String? {
        return accountDto.contract?.product
    }
    
    var contractNumber: String? {
        return accountDto.contract?.contractNumber
    }
}
