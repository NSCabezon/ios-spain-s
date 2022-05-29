//
//  PrivateMenuMainOption.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 4/4/22.
//
import CoreDomain

public struct PrivateMenuMainOption: PrivateMenuOptionRepresentable, Hashable {
    public let imageKey: String
    public let titleKey: String
    public let extraMessageKey: String?
    public let newMessageKey: String?
    public let imageURL: String?
    public let showArrow: Bool
    public var isHighlighted: Bool
    public let type: PrivateMenuOptions
    public let isFeatured: Bool
    public let accesibilityIdentifier: String?
    
    public init(item: PrivateMenuOptionRepresentable) {
        self.imageKey = item.imageKey
        self.titleKey = item.titleKey
        self.extraMessageKey = item.extraMessageKey
        self.newMessageKey = item.newMessageKey
        self.imageURL = item.imageURL
        self.showArrow = item.showArrow
        self.isHighlighted = item.isHighlighted
        self.type = item.type
        self.isFeatured = item.isFeatured
        self.accesibilityIdentifier = item.accesibilityIdentifier
    }
    
    public init(imageKey: String,
         titleKey: String,
         extraMessageKey: String?,
         newMessageKey: String?,
         imageURL: String?,
         showArrow: Bool,
         isHighlighted: Bool,
         type: PrivateMenuOptions,
         isFeatured: Bool,
         accesibilityIdentifier: String?) {
        self.imageKey = imageKey
        self.titleKey = titleKey
        self.extraMessageKey = extraMessageKey
        self.newMessageKey = newMessageKey
        self.imageURL = imageURL
        self.showArrow = showArrow
        self.isHighlighted = isHighlighted
        self.type = type
        self.isFeatured = isFeatured
        self.accesibilityIdentifier = accesibilityIdentifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(imageKey)
        hasher.combine(accesibilityIdentifier)
    }
    static public func == (lhs: PrivateMenuMainOption, rhs: PrivateMenuMainOption) -> Bool {
        return lhs.imageKey == rhs.imageKey
    }
}

