import CoreFoundationLib

struct UserContactPhone {
    let alias: String
    let number: String
    
    var encodingVersion: ContactsSerializationVersion = .v1
    
    init(alias: String, number: String) {
        self.alias = alias
        self.number = number
    }
}

extension UserContactPhone: Encodable {
    private enum CodingKeys: String, CodingKey {
        case alias
        case number
    }
}

extension UserContactPhone: UserContactPhoneRepresentable { }
