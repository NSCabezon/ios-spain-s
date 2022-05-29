//

import Foundation

public struct PersonBasicDataDTO: Codable {
    public var mainAddress: String?
    public var addressNodes: [String]?
    public var correspondenceAddressNodes: [String]?
    public var documentType: DocumentType?
    public var documentNumber: String?
    public var birthDate: Date?
    public var birthString: String?
    public var phoneNumber: String?
    public var smsPhoneNumber: String? = nil
    public var contactHourFrom: Date?
    public var contactHourTo: Date?
    public var email: String?
    public var emailAlternative: String?
    
    public init() {}
    
    public init(mainAddress: String?, addressNodes: [String]?, documentType: DocumentType?, documentNumber: String?, birthDate: Date?, birthString: String? = nil, phoneNumber: String?, contactHourFrom: Date?, contactHourTo: Date?, email: String?, emailAlternative: String? = nil) {
        self.mainAddress = mainAddress
        self.addressNodes = addressNodes
        self.documentType = documentType
        self.documentNumber = documentNumber
        self.birthDate = birthDate
        self.birthString = birthString
        self.phoneNumber = phoneNumber
        self.contactHourFrom = contactHourFrom
        self.contactHourTo = contactHourTo
        self.email = email
        self.emailAlternative = emailAlternative
    }
}
