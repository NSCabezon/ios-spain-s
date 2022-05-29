import Contacts
import CoreFoundationLib

struct UserContact {
    let identifier: String
    let name: String
    let surname: String
    var phones: [UserContactPhone]
    let thumbnail: Data?
    private var encodingVersion: ContactsSerializationVersion = .v1
    
    init(identifier: String, name: String, surname: String, phones: [UserContactPhone], thumbnail: Data?) {
        self.identifier = identifier
        self.name = name
        self.surname = surname
        self.phones = phones
        self.thumbnail = thumbnail
    }
}

extension UserContact {
    var fullName: String {
        return (name + " " + surname).trim()
    }
    
    mutating func set(encodingVersion: ContactsSerializationVersion) {
        self.encodingVersion = encodingVersion
        self.phones = phones.map {
            var phone = $0
            phone.encodingVersion = encodingVersion
            return phone
        }
    }
}

extension UserContact: Encodable {
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case phones = "numbers"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(fullName, forKey: .name)
        switch encodingVersion {
        case .v1:
            try container.encode(self.phones.map { $0.number }, forKey: .phones)
        case .v2:
            try container.encode(phones, forKey: .phones)
        }
    }
}

extension UserContact: UserContactRepresentable {
    var phonesRepresentable: [UserContactPhoneRepresentable] {
        get {
            return self.phones
        }
        set(newValue) {
            self.phones = newValue.map { UserContactPhone(alias: $0.alias, number: $0.number) }
        }
    }
}
