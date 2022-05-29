//
//  FavouriteContactViewModel.swift
//  GlobalPosition
//
//  Created by Ignacio González Miró on 22/09/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public protocol FavouriteContactViewModel: Shareable {
    var contact: PayeeRepresentable { get }
    var baseUrl: String? { get }
    var colorsByNameViewModel: ColorsByNameViewModel { get }
}

extension FavouriteContactViewModel {
    var avatarColor: UIColor {
        return self.colorsByNameViewModel.color
    }
    
    var name: String {
        return self.contact.payeeDisplayName?.camelCasedString ?? ""
    }
    
    var accountNumber: String {
        if contact.shortIBAN.isEmpty {
            return contact.shortAccountNumber ?? ""
        }
        return contact.shortIBAN
    }
    
    var accountNumberPapel: String {
        guard let iban = self.contact.ibanRepresentable else { return accountNumber }
        return iban.ibanPapel
    }
    
    var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    var bankIconUrl: String? {
        guard let entityCode = self.contact.ibanRepresentable?.ibanElec.substring(4, 8),
              let contryCode = self.contact.ibanRepresentable?.countryCode,
              let baseUrl = self.baseUrl
        else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var formattedAccount: String? {
        return self.contact.formattedAccount
    }
}

extension FavouriteContactViewModel {
    func getShareableInfo() -> String {
        return contact.formattedAccount ?? ""
    }
}

struct FavouriteContact: FavouriteContactViewModel {
    let contact: PayeeRepresentable
    let baseUrl: String?
    let colorsByNameViewModel: ColorsByNameViewModel
}
