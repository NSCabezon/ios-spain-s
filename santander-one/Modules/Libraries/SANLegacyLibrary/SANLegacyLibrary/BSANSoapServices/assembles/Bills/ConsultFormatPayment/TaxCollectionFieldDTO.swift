import Foundation


public struct TaxCollectionFieldDTO: Codable  {
    public let fieldDescription: String
    public let fieldId: String
    public let referenceId: String
    public let fieldLength: String
    
    public init?(fieldDescription: String, fieldId: String, referenceId: String, fieldLength: String) {
        self.fieldDescription = fieldDescription
        self.fieldId = fieldId
        self.referenceId = referenceId
        self.fieldLength = fieldLength
    }
}
