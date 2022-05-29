//
//  SepaInfoListRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 24/9/21.
//

import Foundation

public protocol SepaInfoListRepresentable {
    var allCurrenciesRepresentable: [CurrencyInfoRepresentable] { get }
    var allCountriesRepresentable: [CountryInfoRepresentable] { get }
}
