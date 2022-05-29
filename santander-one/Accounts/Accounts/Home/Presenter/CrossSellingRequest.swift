//
//  CrossSellingRequest.swift
//  Account
//
//  Created by Boris Chirino Fernandez on 28/09/2020.
//

import CoreFoundationLib

public struct CrossSellingRequest: Hashable {
    let transaction: AccountTransactionViewModel
    let indexPath: IndexPath
    var pulledOffer: [PullOfferLocation: OfferEntity]?
    var loading: Bool = false
    var calcualtedBannerHeight: CGFloat = 0
    var processed: Bool = false
    var requested: Bool = false
    public static func == (lhs: CrossSellingRequest, rhs: CrossSellingRequest) -> Bool {
       return lhs.transaction == rhs.transaction && lhs.indexPath == rhs.indexPath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(transaction)
        hasher.combine(indexPath)
    }
}
