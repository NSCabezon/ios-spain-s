//
//  BSANSubscriptionManager.swift
//  SanLibraryV3
//
//  Created by Rubén Márquez Fernández on 10/5/21.
//  Copyright © 2021 com.ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary

public final class BSANSubscriptionManagerImplementation: BSANBaseManager, BSANSubscriptionManager {
    private let sanRestServices: SanRestServices

    public init(bsanDataProvider: BSANDataProvider, sanRestServices: SanRestServices) {
        self.sanRestServices = sanRestServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func activate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void> {
        let dataSource = CardSubscriptionsDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: self.bsanDataProvider
        )
        return try dataSource.activateSubscription(magicPhrase: magicPhrase, instaId: instaID)
    }
    
    public func deactivate(magicPhrase: String, instaID: String) throws -> BSANResponse<Void>  {
        let dataSource = CardSubscriptionsDataSource(
            sanRestServices: self.sanRestServices,
            bsanDataProvider: self.bsanDataProvider
        )
        return try dataSource.deactivateSubscription(magicPhrase: magicPhrase, instaId: instaID)
    }
}
