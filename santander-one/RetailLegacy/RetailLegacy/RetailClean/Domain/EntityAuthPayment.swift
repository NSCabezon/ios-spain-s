import SANLegacyLibrary
import Foundation

class EntityAuthPayment {
    static func create(_ from: EntityAuthPaymentDTO) -> EntityAuthPayment {
        return EntityAuthPayment(dto: from)
    }
    
    private(set) var entityAuthPaymentDTO: EntityAuthPaymentDTO
    init(dto: EntityAuthPaymentDTO) {
        entityAuthPaymentDTO = dto
    }
    
    var document: DocumentEntityAuthPayment? {
        guard let documentDTO = entityAuthPaymentDTO.document else { return nil }
        return DocumentEntityAuthPayment(dto: documentDTO)
    }
    
    var address: String? {
        return entityAuthPaymentDTO.address
    }
    
    var town: String? {
        return entityAuthPaymentDTO.town
    }
    
    var typeDocumentDescription: String? {
        return entityAuthPaymentDTO.typeDocumentDescription
    }
}
