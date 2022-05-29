//
//  PrivateMenuOptionRepresentable.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 27/1/22.
//

public protocol PrivateMenuOptionRepresentable: UniqueIdentifiable {
    var imageKey: String { get }
    var titleKey: String { get }
    var extraMessageKey: String? { get }
    var newMessageKey: String? { get }
    var imageURL: String? { get }
    var showArrow: Bool { get }
    var isHighlighted: Bool { get set }
    var type: PrivateMenuOptions { get }
    var isFeatured: Bool { get }
    var accesibilityIdentifier: String? { get }
}

public extension PrivateMenuOptionRepresentable {
    var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(titleKey)
        hasher.combine(imageKey)
        return hasher.finalize()
    }
}
