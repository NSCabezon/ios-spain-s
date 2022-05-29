//
//  PublicProduct.swift
//  Models
//
//  Created by alvola on 29/04/2020.
//

protocol ImageTitleCollectionProtocol {
    var id: String? { get }
    var text: String? { get }
    var icon: String? { get }
    var absoluteUrl: String? { get }
    var offers: [Offer]? { get }
}

public struct PublicProduct: Codable, ImageTitleCollectionProtocol {
    public let id: String?
    public let text: String?
    public let icon: String?
    public let absoluteUrl: String?
    public var offers: [Offer]? {
        return nil
    }
}
