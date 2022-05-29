import SANLegacyLibrary
import Foundation

class ModifyDeferredTransfer {
    private(set) var dto: ModifyDeferredTransferDTO
    
    init(dto: ModifyDeferredTransferDTO) {
        self.dto = dto
    }
    
    var signature: Signature? {
        get {
            guard let signatureDTO = dto.signatureDTO else { return nil }
            return Signature(dto: signatureDTO)
        }
        set {
            dto.signatureDTO = newValue?.dto
        }
    }
}
