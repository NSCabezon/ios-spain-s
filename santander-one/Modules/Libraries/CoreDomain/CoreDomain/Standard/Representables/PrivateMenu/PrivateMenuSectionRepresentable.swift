//
//  PrivateMenuSection.swift
//  CoreFoundationLib
//
//  Created by Boris Chirino Fernandez on 8/3/22.
//

public protocol PrivateSubMenuOptionRepresentable {
    var titleKey: String { get }
    var icon: String? { get }
    var submenuArrow: Bool { get }
    var elementsCount: Int? { get }
    var action: PrivateSubmenuAction { get }
}

public protocol PrivateMenuSectionRepresentable {
    var titleKey: String? { get }
    var items: [PrivateSubMenuOptionRepresentable] { get }
}
