//
//  ContactViewModel.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 31/01/2020.
//

import CoreDomain
import Foundation
import CoreFoundationLib

struct ContactListItemViewModel: ContactViewModel {
    let contact: PayeeRepresentable
    let baseUrl: String?
    let sepaInfoList: SepaInfoListEntity
    let colorsByNameViewModel: ColorsByNameViewModel
    let showCurrencySymbol: Bool

    var currency: String? {
        if showCurrencySymbol {
            guard let currency = self.contact.currencyName.flatMap(sepaInfoList.currencyFor) else { return nil }
            if let currencySymbol = self.contact.currencyName.flatMap(sepaInfoList.currencySymbolFor) {
                return currency + " (\(currencySymbol))"
            }
        }
        return self.contact.currencyName.flatMap(sepaInfoList.currencyFor)
    }
    
    var countryCode: String? {
        return self.contact.countryCode.flatMap(sepaInfoList.countryFor)
    }
    
    var areCountryAndCurrencyNil: Bool {
        return self.countryCode == nil && self.currency == nil ? true : false
    }
    
    var isCountryViewHidden: Bool {
        return self.countryCode == nil && self.currency != nil ? true : false
    }
    
    var isCurrencyViewHidden: Bool {
        return self.countryCode != nil && self.currency == nil ? true : false
    }
}
