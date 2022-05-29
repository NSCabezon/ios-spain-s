//
//  FeeDataRepresentable.swift
//  Cards
//
//  Created by Gloria Cano López on 5/4/22.
//

public protocol FeeDataRepresentable {
    var minPeriodCount: Int? { get }
    var maxPeriodCount: Int? { get }
    var periodInc: Int? { get }
    var minFeeAmount: String? { get }
    var JPORCEA1: String? { get }
    var JTIPOLI: String? { get }
    var JTIPRAN: String? { get }
    var LIMITPO1: String? { get }
    var MLFORPA1: String? { get }
}
