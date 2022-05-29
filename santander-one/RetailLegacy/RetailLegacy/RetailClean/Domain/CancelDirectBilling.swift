import SANLegacyLibrary
import Foundation

struct CancelDirectBilling {
    
    static func create(_ from: GetCancelDirectBillingDTO) -> CancelDirectBilling {
        return CancelDirectBilling(dto: from)
    }
    
    let cancelDirectBillingDTO: GetCancelDirectBillingDTO
    
    internal init(dto: GetCancelDirectBillingDTO) {
        cancelDirectBillingDTO = dto
    }
    
    var tipauto: String {
        return cancelDirectBillingDTO.tipauto
    }
    
    var cdinaut: String {
        return cancelDirectBillingDTO.cdinaut
    }
}
