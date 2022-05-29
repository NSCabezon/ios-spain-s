//
//  ContactPermissionsManager.swift
//  Commons
//
//  Created by Carlos Gutiérrez Casado on 30/04/2020.
//

import Foundation

public enum ContactsPersmissionError {
    case denied
    case unknown
}

public enum ContactsPersmissionStatus {
    case success
    case failure(error: ContactsPersmissionError)
}

public protocol ContactPermissionsManagerProtocol: AnyObject {
    func isContactsAccessEnabled() -> Bool
    func isAlreadySet(completion: @escaping (Bool) -> Void)
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void)
    func getContacts(includingImages: Bool, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void)
}
