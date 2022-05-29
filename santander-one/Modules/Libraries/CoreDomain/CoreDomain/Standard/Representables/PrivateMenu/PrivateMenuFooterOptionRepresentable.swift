//
//  PrivateMenuFooterOptionRepresentable.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 22/12/21.
//

public enum FooterOptionType {
    case security
    case atm
    case helpCenter
    case myManager
}

public protocol PrivateMenuFooterOptionRepresentable: UniqueIdentifiable {
    var title: String { get }
    var imageName: String { get }
    var imageURL: String? { get }
    var accessibilityIdentifier: String { get }
    var optionType: FooterOptionType { get }
}

public extension PrivateMenuFooterOptionRepresentable {
    var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(imageName)
        return hasher.finalize()
    }
}
