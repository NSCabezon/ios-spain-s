//
//  CardMovementLocationRepresentable.swift
//  CoreDomain
//
//  Created by Hernán Villamil on 21/2/22.
//

import Foundation

public protocol CardMovementLocationRepresentable {
    var date: Date? { get }
    var amountRepresentable: AmountRepresentable? { get }
    var concept: String? { get }
    var address: String? { get }
    var location: String? { get }
    var category: String? { get }
    var subcategory: String? { get }
    var latitude: Double? { get }
    var longitude: Double? { get }
    var postalCode: String? { get }
    var status: String? { get }
}
