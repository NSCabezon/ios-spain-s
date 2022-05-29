//
//  Offer.swift
//  Models
//
//  Created by alvola on 29/04/2020.
//
import CoreDomain

extension Dictionary where Key == PullOfferLocation, Value == Offer {
    
    public func location(key: String) -> (location: PullOfferLocation, offer: Offer)? {
        guard let location = self.first(where: { $0.key.stringTag == key }) else { return nil }
        return (location.key, location.value)
    }
}

extension Dictionary where Key == PullOfferLocation, Value == OfferRepresentable {
    
    public func location(key: String) -> (location: PullOfferLocation, offer: OfferRepresentable)? {
        guard let location = self.first(where: { $0.key.stringTag == key }) else { return nil }
        return (location.key, location.value)
    }
}

public struct Offer {
    private let dto: OfferDTO
    var id: String? {
        return dto.product.identifier
    }
    var action: OfferActionRepresentable? {
        return dto.product.action
    }
    var banners: [Banner] {
        return dto.product.banners.compactMap { Banner.createFromDTO($0) }
    }
    var bannersContracts: [Banner] {
        return dto.product.bannersContract.compactMap { Banner.createFromDTO($0) }
    }
    
    init(offerDTO: OfferDTO) {
        dto = offerDTO
    }
}

protocol LoginMessagesData {
    static var hash: String { get }
}

extension Offer: LoginMessagesData {
    static var hash: String {
        return "PullOffer"
    }
}
