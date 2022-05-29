public struct UserContactEntity {
    public let identifier: String
    public let name: String
    public let surname: String
    public let phones: [UserContactPhoneEntity]
    public let thumbnail: Data?
    
    public init(identifier: String, name: String, surname: String, thumbnail: Data?, phones: [UserContactPhoneEntity]) {
        self.identifier = identifier
        self.name = name
        self.surname = surname
        self.phones = phones
        self.thumbnail = thumbnail
    }
}

public extension UserContactEntity {
    var fullName: String {
        return (name + " " + surname).trim()
    }
}

// Internal array from iOS Contact
public struct UserContactPhoneEntity {
    public let alias: String
    public let number: String
    
    public init(alias: String, number: String) {
        self.alias = alias
        self.number = number
    }
}
