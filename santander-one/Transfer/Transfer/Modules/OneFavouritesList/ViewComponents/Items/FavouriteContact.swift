//
//  FavouriteContact.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 10/1/22.
//

import CoreFoundationLib
import CoreDomain

final class FavouriteContact {
    private let contact: PayeeRepresentable
    private let sepaInfoList: SepaInfoListRepresentable?
    private let legacyDependenciesResolver: DependenciesResolver
    
    init(contact: PayeeRepresentable,
         sepaInfoList: SepaInfoListRepresentable?,
         legacyDependenciesResolver: DependenciesResolver) {
        self.contact = contact
        self.sepaInfoList = sepaInfoList
        self.legacyDependenciesResolver = legacyDependenciesResolver
    }
    
    var oneAvatar: OneAvatarViewModel {
        return OneAvatarViewModel(fullName: contact.payeeDisplayName,
                                  dependenciesResolver: legacyDependenciesResolver)
    }
    
    var alias: String {
        return contact.payeeAlias?.camelCasedString ?? ""
    }
    
    var holder: String {
        return contact.payeeName?.camelCasedString ?? ""
    }
    
    var accountNumber: String {
        return contact.formattedAccount ?? ""
    }
    
    var bankIconUrl: String? {
        let baseURLProvider: BaseURLProvider = legacyDependenciesResolver.resolve()
        guard let entityCode = contact.entityCode,
              let countryCode = contact.countryCode,
              let baseUrl = baseURLProvider.baseURL
        else { return nil }
        return String(format: "%@%@/%@_%@%@",
                      baseUrl,
                      GenericConstants.relativeURl,
                      countryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var country: String? {
        guard let countryCode = contact.countryCode,
              let country = sepaInfoList?.allCountriesRepresentable.first(where: { $0.code == countryCode })?.name,
              let currency = contact.currencyName
        else { return nil }
        return country + " (\(currency))"
    }
}

extension FavouriteContact: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(contact.payeeId)
    }
}

extension FavouriteContact: Equatable {
    static func == (lhs: FavouriteContact, rhs: FavouriteContact) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
