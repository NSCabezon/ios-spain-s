import Foundation
import SANLegacyLibrary
import CoreFoundationLib

class SavingProduct: GenericProduct {
    let savingProductEntity: SavingProductEntity

    init(_ entity: SavingProductEntity) {
        self.savingProductEntity = entity
        super.init()
    }
    
    convenience init(dto: SavingProductDTO) {
        self.init(SavingProductEntity(dto))
    }
}

extension SavingProduct {
    var savingProductDTO: SavingProductDTO {
        return savingProductEntity.dto
    }
}
