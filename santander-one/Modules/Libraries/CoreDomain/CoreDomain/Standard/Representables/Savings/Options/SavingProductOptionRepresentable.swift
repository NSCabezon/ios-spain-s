//
//  SavingProductOptionRepresentable.swift
//  SavingProducts
//
//  Created by José Norberto Hidalgo Romero on 23/2/22.
//

import Foundation

public enum SavingProductOptionType {
    case sendMoney
    case statements
    case regularPayments
    case reportCard
    case apply
    case custom(identifier: String)
}

public enum SavingsActionSection: String, CaseIterable {
    case settings
    case queries
    case offer
}

public protocol SavingProductOptionRepresentable: UniqueIdentifiable {
    var title: String { get }
    var imageName: String { get }
    var imageColor: UIColor? { get }
    var accessibilityIdentifier: String { get }
    var type: SavingProductOptionType { get }
    var titleIdentifier: String? { get }
    var imageIdentifier: String? { get }
    var otherOperativesSection: SavingsActionSection? { get }
}

public extension SavingProductOptionRepresentable {
    var uniqueIdentifier: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(imageName)
        return hasher.finalize()
    }
}
