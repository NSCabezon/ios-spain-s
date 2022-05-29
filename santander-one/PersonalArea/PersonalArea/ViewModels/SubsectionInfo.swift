//
//  SubsectionInfo.swift
//  PersonalArea
//
//  Created by alvola on 13/08/2020.
//

import CoreFoundationLib

public struct SubsectionInfo {
    let iconName: String
    let title: LocalizedStylableText?
    let iconAccessibilityIdentifier: String?
    let titleAccessibilityIdentifier: String?
    let arrowAccessibilityIdentifier: String?
    let goToSection: PersonalAreaSection?
    let action: PersonalAreaAction?
    
    public init(iconName: String, title: LocalizedStylableText?, iconAccessibilityIdentifier: String? = nil, titleAccessibilityIdentifier: String? = nil, arrowAccessibilityIdentifier: String? = nil, goToSection: PersonalAreaSection? = nil, action: PersonalAreaAction? = nil) {
        self.iconName = iconName
        self.title = title
        self.goToSection = goToSection
        self.action = action
        self.iconAccessibilityIdentifier = iconAccessibilityIdentifier
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier
        self.arrowAccessibilityIdentifier = arrowAccessibilityIdentifier
    }
}
