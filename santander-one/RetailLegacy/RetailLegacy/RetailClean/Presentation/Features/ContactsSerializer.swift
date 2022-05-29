import Foundation

protocol ContactsSerializer {
    static var serializationVersion: ContactsSerializationVersion { get }
    
    static func serialize(contacts: [UserContact]) -> String?
}

extension ContactsSerializer {
    static func serialize(contacts: [UserContact]) -> String? {
        let contacts: [UserContact] = contacts.map {
            var contact = $0
            contact.set(encodingVersion: serializationVersion)
            return contact
        }
        guard let data = try? JSONEncoder().encode(contacts) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

struct V1ContactsSerializer {
}

extension V1ContactsSerializer: ContactsSerializer {
    static var serializationVersion: ContactsSerializationVersion {
        return .v1
    }
}

struct V2ContactsSerializer {
}

extension V2ContactsSerializer: ContactsSerializer {
    static var serializationVersion: ContactsSerializationVersion {
        return .v2
    }
}
