//
//  ContactDetailConfiguration.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 29/04/2020.
//

import CoreDomain
import Foundation
import CoreFoundationLib

public struct ContactDetailConfiguration {
    let contact: PayeeRepresentable
    let account: AccountEntity?
    
    public init(contact: PayeeRepresentable, account: AccountEntity?) {
        self.contact = contact
        self.account = account
    }
}

struct ContactDetailExtendedConfiguration {
    let favorite: FavoriteType
    let sepaList: SepaInfoListEntity
}
