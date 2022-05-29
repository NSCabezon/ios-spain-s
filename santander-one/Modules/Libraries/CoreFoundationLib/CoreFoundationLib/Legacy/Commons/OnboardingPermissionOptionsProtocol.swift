//
//  OnboardingPermissionOptions.swift
//  Commons
//
//  Created by José Norberto Hidalgo Romero on 31/1/22.
//

import Foundation

public protocol OnboardingPermissionOptionsProtocol {
    func getOptions() -> [OnboardingPermissionType]
}

public typealias OnboardingPermissions = [OnboardingPermissionItem]
public typealias OnboardingPermissionItem = (OnboardingPermissionType, [Bool])

public enum OnboardingPermissionType: Equatable {
    case notifications(title: String?)
    case location(title: String?)
    case custom(options: CustomOptionOnboarding)
    case customWithTooltip(options: CustomOptionWithTooltipOnboarding)
    
    public static var notifications: OnboardingPermissionType {
        return .notifications(title: nil)
    }
    public static var location: OnboardingPermissionType {
        return .location(title: nil)
    }
    
    public static func == (lhs: OnboardingPermissionType, rhs: OnboardingPermissionType) -> Bool {
        switch (lhs, rhs) {
        case let (.notifications(lhsTitle), notifications(rhsTitle)) :
            return lhsTitle == rhsTitle
        case let (.location(lhsTitle), location(rhsTitle)):
            return lhsTitle == rhsTitle
        case let (.custom(lhsOptions), custom(rhsOptions)):
            return lhsOptions.titleKey == rhsOptions.titleKey
        case let (.customWithTooltip(lhsOptions), customWithTooltip(rhsOptions)) :
            return lhsOptions.titleKey == rhsOptions.titleKey
        default:
            return false
        }
    }
}

public final class CustomOptionOnboarding {
    public let imageName: String
    public let titleKey: String
    public let textKey: String
    public let switchText: String?
    public let isEnabled: () -> Bool
    public let action: (_ completion: @escaping (Bool) -> Void) -> Void
    
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

public final class CustomOptionWithTooltipOnboarding {
    public let imageName: String
    public let titleKey: String
    public let textKey: String
    public let cell: [CustomOptionWithTooltipContentOnboarding]
    
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
    public let iconName: String
    public let iconTextKey: String
    public let tooltipKey: String
    public let tooltipImage: String
    public let tooltipActive: Bool
    public let isEnabled: () -> Bool
    public let action: (_ completion: @escaping (Bool) -> Void) -> Void
    
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
