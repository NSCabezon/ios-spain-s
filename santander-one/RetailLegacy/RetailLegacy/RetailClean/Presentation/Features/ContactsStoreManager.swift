import Contacts
import Foundation
import CoreFoundationLib

enum ContactsSerializationVersion {
    case v1
    case v2
    
    var serializer: ContactsSerializer.Type {
        switch self {
        case .v1:
            return V1ContactsSerializer.self
        case .v2:
            return V2ContactsSerializer.self
        }
    }
}

class ContactsStoreManager {
    private let store = CNContactStore()
    
    func serialize(contacts: [UserContact], forVersion version: ContactsSerializationVersion) -> String? {
        return version.serializer.serialize(contacts: contacts)
    }
    
    func scanContacts(completion: @escaping ([UserContact]?, ContactsPersmissionStatus) -> Void) {
        func getContactsFromStore() -> [CNContact]? {
            let keys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey].map { $0 as NSString }
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            do {
                var contacts = [CNContact]()
                try store.enumerateContacts(with: request) { contact, _ in
                    contacts.append(contact)
                }
                return contacts
            } catch {
                return nil
            }
        }
        
        func convert(contacts: [CNContact]?) -> [UserContact]? {
            return contacts?.map { $0.userContact }
        }
        
        getPermissionStatus { status in
            let contacts: [UserContact]?
            switch status {
            case .success:
                contacts = convert(contacts: getContactsFromStore())
            case .failure:
                contacts = nil
            }
            DispatchQueue.main.async {
                completion(contacts, status)
            }
        }
    }
    
    private func getPermissionStatus(completion: @escaping (ContactsPersmissionStatus) -> Void) {
        func convert(error: Error?) -> ContactsPersmissionError {
            return .unknown
        }
        
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completion(.success)
        case .denied:
            completion(.failure(error: .denied))
        case .restricted, .notDetermined:
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completion(.success)
                } else {
                    completion(.failure(error: convert(error: error)))
                }
            }
        @unknown default:
            completion(.failure(error: .denied))
        }
    }
    
    var isPermissionEnabledStatus: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }
    
    var isAlreadySet: Bool {
        return CNContactStore.authorizationStatus(for: .contacts) != .notDetermined
    }
    
}

extension CNContact {
    var userContact: UserContact {
        let phones = phoneNumbers.map {
            return UserContactPhone(alias: CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: $0.label ?? ""), number: $0.value.stringValue)
        }
        return UserContact(identifier: identifier, name: givenName, surname: familyName, phones: phones, thumbnail: thumbnailImageData)
    }
}

extension ContactsStoreManager: ContactPermissionsManagerProtocol {
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        getPermissionStatus { _ in
            DispatchQueue.main.async {
                completion(self.isPermissionEnabledStatus)
            }
        }
    }
    
    func isContactsAccessEnabled() -> Bool {
        return isPermissionEnabledStatus
    }

    func isAlreadySet(completion: @escaping (Bool) -> Void) {
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
             completion(false)
        } else {
            completion(true)
        }
    }
    
    func getContacts(includingImages: Bool = false, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void) {
        self.scanContacts { contacts, status in
            guard let contacts = contacts else { return completion(nil, status) }
            let contactsEntity = contacts.map { UserContactEntity(identifier: $0.identifier, name: $0.name, surname: $0.surname, thumbnail: includingImages ? $0.thumbnail : nil, phones: $0.phones.map { UserContactPhoneEntity(alias: $0.alias, number: $0.number) }) }
            completion(contactsEntity, status)
        }
    }
}
