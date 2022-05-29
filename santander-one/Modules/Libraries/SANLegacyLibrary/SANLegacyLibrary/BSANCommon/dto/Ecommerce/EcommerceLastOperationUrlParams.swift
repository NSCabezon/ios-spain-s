import Foundation

public struct EcommerceLastOperationUrlParams: Codable {
    public let documentType: String
    public let documentNumber: String
    
    public init(documentType: String, documentNumber: String) {
        self.documentType = documentType
        self.documentNumber = documentNumber
    }
}
