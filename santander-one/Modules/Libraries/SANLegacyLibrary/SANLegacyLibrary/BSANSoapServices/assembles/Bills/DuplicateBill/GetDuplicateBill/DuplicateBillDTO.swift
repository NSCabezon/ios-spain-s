import Foundation

public struct DuplicateBillDTO {
    public let signature: SignatureDTO
    public let concept: String?
    public let datePayment: Date?
    public let reference: String?
    
    public init(signature: SignatureDTO, concept: String?, datePayment: Date?, reference: String?) {
        self.signature = signature
        self.concept = concept
        self.datePayment = datePayment
        self.reference = reference
    }
}
