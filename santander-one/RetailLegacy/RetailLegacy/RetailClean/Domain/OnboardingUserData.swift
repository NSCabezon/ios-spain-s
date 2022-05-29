//
//  OnboardingUserData.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 17/12/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary

public typealias FirstBoardingPermissionTypeItem = (FirstBoardingPermissionType, [Bool])

public final class OnboardingUserData {
    
    let userId: String
    var userName: String
    var userAlias: String
    var currentLanguage: Language
    let loginType: UserLoginType?
    let languages: [LanguageType]
    var items: [FirstBoardingPermissionTypeItem]
    var globalPositionOnboardingSelectedValue: Int
    let photoThemeOnboardingSelectedValue: Int?
    var smartThemeColor: Int
    
    init(userId: String, username: String, userAlias: String, currentLanguage: Language, loginType: UserLoginType?, languages: [LanguageType], items: [FirstBoardingPermissionTypeItem], globalPositionOnboardingSelectedValue: Int, photoThemeOnboardingSelectedValue: Int?, smartThemeColorId: Int) {
        self.userId = userId
        self.userName = username
        self.userAlias = userAlias
        self.currentLanguage = currentLanguage
        self.loginType = loginType
        self.languages = languages
        self.items = items
        self.globalPositionOnboardingSelectedValue = globalPositionOnboardingSelectedValue
        self.photoThemeOnboardingSelectedValue = photoThemeOnboardingSelectedValue
        self.smartThemeColor = smartThemeColorId
    }
}

public enum FirstBoardingPermissionType {
    case touchId
    case notifications(title: String?)
    case location(title: String?)
    case custom(options: CustomOptionOnbarding)
    case customWithTooltip(options: CustomOptionWithTooltipOnbarding)
    
    public static var notifications: FirstBoardingPermissionType {
        return .notifications(title: nil)
    }
    public static var location: FirstBoardingPermissionType {
        return .location(title: nil)
    }
}

public final class CustomOptionOnbarding {
    let imageName: String
    let titleKey: String
    let textKey: String
    let switchText: String?
    let isEnabled: () -> Bool
    let action: (_ completion: @escaping (Bool) -> Void) -> Void
    
    public init(imageName: String,
                titleKey: String,
                textKey: String,
                switchText: String? = nil,
                isEnabled: @escaping () -> Bool,
                action: @escaping (_ completion: @escaping (Bool) -> Void) -> Void) {
        self.imageName = imageName
        self.titleKey = titleKey
        self.textKey = textKey
        self.switchText = switchText
        self.isEnabled = isEnabled
        self.action = action
    }
}

public final class CustomOptionWithTooltipOnbarding {
    let imageName: String
    let titleKey: String
    let textKey: String
    let cell: [CustomOptionWithTooltipContentOnboarding]
    
    public init(imageName: String,
                titleKey: String,
                textKey: String,
                cell: [CustomOptionWithTooltipContentOnboarding]) {
        self.imageName = imageName
        self.titleKey = titleKey
        self.textKey = textKey
        self.cell = cell
    }
}

public final class CustomOptionWithTooltipContentOnboarding {
    let iconName: String
    let iconTextKey: String
    let tooltipKey: String
    let tooltipImage: String
    let tooltipActive: Bool
    let isEnabled: () -> Bool
    let action: (_ completion: @escaping (Bool) -> Void) -> Void
    
    public init(iconName: String,
                iconTextKey: String,
                tooltipKey: String,
                tooltipImage: String,
                tooltipActive: Bool = true,
                isEnabled: @escaping () -> Bool,
                action: @escaping (_ completion: @escaping (Bool) -> Void) -> Void) {
        self.isEnabled = isEnabled
        self.action = action
        self.iconName = iconName
        self.tooltipKey = tooltipKey
        self.tooltipImage = tooltipImage
        self.tooltipActive = tooltipActive
        self.iconTextKey = iconTextKey
    }
}
