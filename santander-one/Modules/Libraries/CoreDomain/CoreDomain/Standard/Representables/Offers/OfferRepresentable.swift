//
//  OfferRepresentable.swift
//  CoreDomain
//
//  Created by Carlos Monfort Gómez on 29/11/21.
//

import Foundation

public protocol OfferRepresentable {
    var pullOfferLocation: PullOfferLocationRepresentable? { get }
    var bannerRepresentable: BannerRepresentable? { get }
    var action: OfferActionRepresentable? { get }
    @available(*, deprecated, message: "Use identifier instead")
    var id: String? { get }
    var identifier: String { get }
    var transparentClosure: Bool { get }
    var productDescription: String { get }
    var rulesIds: [String] { get }
    var startDateUTC: Date? { get }
    var endDateUTC: Date? { get }
}

public extension OfferRepresentable {
    func equalsTo(other: OfferRepresentable) -> Bool {
        return self.identifier == other.identifier &&
        self.transparentClosure == other.transparentClosure &&
        self.productDescription == other.productDescription
    }
}
