//
//  SelectOptionButtonModel.swift
//  Santander
//
//  Created by Juan Jose Acosta González on 25/1/22.
//
import CoreFoundationLib

struct SelectOptionButtonModel: SelectOptionButtonModelRepresentable {
    public var titleKey: String
    public var action: PublicMenuAction
    public var node: KindOfPublicMenuNode
    public var accessibilityIdentifier: String?
    public var event: String
}
