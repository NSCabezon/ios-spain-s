//
//  CrossSellingRepresentable.swift
//  Commons
//
//  Created by Margaret López Calderón on 13/8/21.
//

import Foundation

public protocol CrossSellingRepresentable {
    var tagsCrossSelling: [String] { get }
    var amountCrossSelling: Decimal? { get }
    var actionNameCrossSelling: String { get }
    var cardTypeCrossSelling: [String: String]? { get }
    var accountAmountCrossSelling: Decimal? { get }
    var crossSellingType: CrossSellingType { get }
}

public extension CrossSellingRepresentable {
    var cardTypeCrossSelling: [String: String]? {
        nil
    }
    var accountAmountCrossSelling: Decimal? {
        0
    }
}

public enum CrossSellingType {
    case cards
    case accounts
}
