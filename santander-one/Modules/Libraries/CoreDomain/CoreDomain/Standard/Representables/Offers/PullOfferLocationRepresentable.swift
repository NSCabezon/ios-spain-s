//
//  PullOfferLocationRepresentable.swift
//  CoreDomain
//
//  Created by Carlos Monfort Gómez on 29/11/21.
//

import Foundation

public protocol PullOfferLocationRepresentable {
    var stringTag: String { get }
    var hasBanner: Bool { get }
    var pageForMetrics: String? { get }
}

public extension PullOfferLocationRepresentable {
    func equalsTo(other: PullOfferLocationRepresentable) -> Bool {
        return self.stringTag == other.stringTag &&
            self.hasBanner == other.hasBanner
    }
}
