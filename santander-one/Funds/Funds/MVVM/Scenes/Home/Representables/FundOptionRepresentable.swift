//
//  FundOptionRepresentable.swift
//  Funds
//
import Foundation
import CoreFoundationLib
import CoreDomain

public enum FundOptionType {
    case custom(identifier: String)
}

public protocol FundOptionRepresentable: UniqueIdentifiable {
    var title: String { get }
    var imageName: String { get }
    var accessibilityIdentifier: String { get }
    var type: FundOptionType { get }
    var titleIdentifier: String? { get }
    var imageIdentifier: String? { get }
}

public extension FundOptionRepresentable {
    var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(self.title)
        hasher.combine(self.imageName)
        return hasher.finalize()
    }
}
