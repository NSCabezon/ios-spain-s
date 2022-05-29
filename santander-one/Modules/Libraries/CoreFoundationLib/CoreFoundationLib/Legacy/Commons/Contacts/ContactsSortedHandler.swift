//
//  ContactsSortedHandler.swift
//  Commons
//
//  Created by Victor Carrilero García on 21/04/2021.
//

import CoreDomain

public final class ContactsSortedHandler: ContactsSortedHandlerProtocol {
    public init() {}
    
    public func sortContacts(_ contacts: [PayeeRepresentable]) -> [PayeeRepresentable] {
        return contacts.sorted(by: { $0.payeeDisplayName?.lowercased() ?? "" < $1.payeeDisplayName?.lowercased() ?? "" })
    }
}
