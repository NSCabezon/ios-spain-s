//
//  PrivateSubMenuOfferRepresentable.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 10/3/22.
//

import Foundation

public protocol PrivateSubMenuOfferRepresentable {
    var url: String { get }
    var insertedHeight: CGFloat? { get }
    var bannerOffer: OfferRepresentable? { get }
    var insets: UIEdgeInsets? { get }
}

