import SANLibraryV3
import Foundation
import SANLegacyLibrary

struct Account {
    let accountDTO: AccountDTO
    var productIdentifier: String {
        return accountDTO.contract?.formattedValue ?? ""
    }
    
    func getCounterValueAmountValue() -> Decimal? {
        return accountDTO.countervalueCurrentBalanceAmount?.value
    }
    
    func getAmount() -> Amount? {
        guard let amountDTO = accountDTO.currentBalance else {
            return nil
        }
        return Amount(amountDTO: amountDTO)
    }
    
    func isAccountHolder() -> Bool {
        let titularRetail = OwnershipType.holder.rawValue == accountDTO.ownershipType
        let titularPB = OwnershipTypeDesc.holder.rawValue == accountDTO.ownershipTypeDesc?.rawValue
        return titularRetail || titularPB
    }
}
