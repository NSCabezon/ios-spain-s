import SANLegacyLibrary
import Foundation

struct BillList {
    
    static func create(_ from: BillListDTO) -> BillList {
        return BillList(dto: from)
    }
    
    let billListDTO: BillListDTO
    
    internal init(dto: BillListDTO) {
        billListDTO = dto
    }
    
}
