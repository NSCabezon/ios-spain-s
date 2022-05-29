//
//  ContactDetailModifier.swift
//  Transfer
//
//  Created by Luis Escámez Sánchez on 16/04/2021.
//

import CoreFoundationLib
import CoreDomain

public protocol ContactDetailModifierProtocol {
    func didSelectTransferForFavorite(_ favorite: PayeeRepresentable, accountEntity: AccountEntity?, enabledFavouritesCarrusel: Bool)
}
