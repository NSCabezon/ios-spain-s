//
//  CardTransactionDetailLocationViewModel.swift
//  Cards
//
//  Created by Iván Estévez on 19/05/2020.
//

import Foundation

struct CardTransactionDetailLocationItem {
    let title: String?
    let address: String?
    let location: String?
    let postalCode: String?
    let category: String?
    let showMapButton: Bool
    
    var decoratedAddress: String {
        var text = ""
        if let address = address, !address.isEmpty {
            text += address
        }
        if let location = location, !location.isEmpty {
            text += ", "
            text += location
        }
        if let postalCode = postalCode, !postalCode.isEmpty {
            text += ", "
            text += postalCode
        }
        return text
    }
}

extension CardTransactionDetailLocationItem: CardTransactionDetailLocationRepresentable {}
