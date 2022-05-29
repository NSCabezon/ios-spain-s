//
//  CurrencyInfoRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 24/9/21.
//

import Foundation

public protocol CurrencyInfoRepresentable {
    var name: String { get }
    var symbol: String? { get }
    var code: String { get }
    
    func equalsTo(other: CurrencyInfoRepresentable) -> Bool
}

public extension CurrencyInfoRepresentable {
    func equalsTo(other: CurrencyInfoRepresentable) -> Bool {
        return self.name == other.name &&
        self.symbol == other.symbol &&
        self.code == other.code
    }
}
