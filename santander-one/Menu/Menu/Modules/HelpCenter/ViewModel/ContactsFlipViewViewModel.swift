//
//  ContactsFlipViewViewModel.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 09/03/2020.
//

import CoreFoundationLib

public enum FlipViewType {
    case superline
    case stolen
}

public enum FlipViewStyle {
    case showNumberLabel
    case hideNumberLabel
}

public struct ContactsFlipViewViewModel {
    let title: String?
    let subtitle: LocalizedStylableText?
    let icon: String
    let viewStyle: FlipViewStyle
    let phoneIcon: String
    let phoneNumbers: [String]?
    public let flipViewType: FlipViewType
    let extraLabel: LocalizedStylableText?
    
    public init(title: String?, subtitle: LocalizedStylableText?, icon: String, phoneIcon: String, phoneNumbers: [String]?, flipViewType: FlipViewType, viewStyle: FlipViewStyle = .showNumberLabel, extraLabel: LocalizedStylableText? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.phoneIcon = phoneIcon
        self.phoneNumbers = phoneNumbers
        self.flipViewType = flipViewType
        self.viewStyle = viewStyle
        self.extraLabel = extraLabel
    }
}
