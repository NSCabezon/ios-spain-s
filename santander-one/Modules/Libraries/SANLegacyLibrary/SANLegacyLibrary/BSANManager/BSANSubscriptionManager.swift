//
//  BSANSuscriptionsManager.swift
//
//  Created by Rubén Márquez Fernández on 5/5/21.
//

import Foundation

public protocol BSANSubscriptionManager {
    func activate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void>
    func deactivate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void>
}
