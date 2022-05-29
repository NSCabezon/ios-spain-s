import SANLegacyLibrary
import Foundation

class DocumentEntityAuthPayment {
    static func create(_ from: DocumentEntityAuthPaymentDTO) -> DocumentEntityAuthPayment {
        return DocumentEntityAuthPayment(dto: from)
    }
    
    private(set) var documentEntityAuthPaymentDTO: DocumentEntityAuthPaymentDTO
    init(dto: DocumentEntityAuthPaymentDTO) {
        documentEntityAuthPaymentDTO = dto
    }
    
    var type: String? {
        return documentEntityAuthPaymentDTO.type
    }
    
    var code: String? {
        return documentEntityAuthPaymentDTO.code
    }
}
