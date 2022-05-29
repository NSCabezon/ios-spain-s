//
//  CardMapItemRepresentable.swift
//  Cards
//
//  Created by Hernán Villamil on 21/2/22.
//

import Foundation

public protocol CardMapItemRepresentable {
    var date: Date? { get }
    var name: String? { get }
    var alias: String? { get }
    var amountRepresentable: AmountRepresentable? { get }
    var address: String? { get }
    var postalCode: String? { get }
    var location: String? { get }
    var latitude: Double { get }
    var longitude: Double { get }
    var amountValue: Decimal? { get }
    var totalValues: Decimal { get }
}
