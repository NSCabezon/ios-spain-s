//
//  CountryInfoRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 24/9/21.
//

import Foundation

public protocol CountryInfoRepresentable {
    var code: String { get }
    var name: String { get }
    var currency: String? { get }
    var bbanLength: Int? { get }
    var sepa: Bool { get }
    var fxpay: Bool? { get }
    var isAlphanumeric: Bool? { get }
}
