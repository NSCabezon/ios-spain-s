//
//  PullOfferTipRepresentable.swift
//  CoreDomain
//
//  Created by Cristobal Ramos Laina on 24/11/21.
//

import Foundation

public protocol PullOfferTipRepresentable {
    var title: String? { get }
    var description: String? { get }
    var icon: String? { get }
    var offerId: String? { get }
    var tag: String? { get }
    var offerRepresentable: OfferRepresentable? { get }
    var keyWords: [String]? { get }
}
