//
//  CardTransactionDetailLocationRepresentable.swift
//  Pods
//
//  Created by Hernán Villamil on 21/4/22.
//

import Foundation

protocol CardTransactionDetailLocationRepresentable {
    var title: String? { get }
    var address: String? { get }
    var location: String? { get }
    var postalCode: String? { get }
    var category: String? { get }
    var showMapButton: Bool { get }
}
