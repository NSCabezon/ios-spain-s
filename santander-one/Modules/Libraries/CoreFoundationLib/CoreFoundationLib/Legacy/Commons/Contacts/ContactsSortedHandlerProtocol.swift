//
//  ContactsSortedHandlerProtocol.swift
//  Commons
//
//  Created by Victor Carrilero García on 21/04/2021.
//

import CoreDomain

public protocol ContactsSortedHandlerProtocol {
    func sortContacts(_ contacts: [PayeeRepresentable]) -> [PayeeRepresentable]
}
