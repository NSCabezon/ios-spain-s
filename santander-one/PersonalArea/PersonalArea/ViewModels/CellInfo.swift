//
//  CellInfo.swift
//  PersonalArea
//
//  Created by alvola on 13/08/2020.
//
import CoreFoundationLib

public typealias CustomAction = (_ completion: @escaping (Bool) -> Void) -> Void
public typealias ExternalAction = () -> Void

public struct CellInfo: PersonalAreaCellInfoRepresentable {
    public let cellClass: String
    public let info: Any?
    public let goToSection: PersonalAreaSection?
    public let action: PersonalAreaAction?
    public let customAction: CustomAction?
    public init(cellClass: String, info: Any?, goToSection: PersonalAreaSection? = nil, action: PersonalAreaAction? = nil, customAction: CustomAction? = nil) {
        self.cellClass = cellClass
        self.info = info
        self.goToSection = goToSection
        self.action = action
        self.customAction = customAction
    }
}

public struct GeneralSectionModel {
    let title: String
    let description: String
    let icon: String
    let titleAccessibilityIdentifier: String
    let descriptionAccessibilityIdentifier: String
    let iconAccessibilityIdentifier: String
    let arrowAccessibilityIdentifier: String
    let subsection: SubsectionInfo?
    
    public init(title: String, description: String, icon: String, titleAccessibilityIdentifier: String, descriptionAccessibilityIdentifier: String, iconAccessibilityIdentifier: String, arrowAccessibilityIdentifier: String, subsection: SubsectionInfo? = nil) {
        self.title = title
        self.description = description
        self.icon = icon
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier
        self.descriptionAccessibilityIdentifier = descriptionAccessibilityIdentifier
        self.iconAccessibilityIdentifier = iconAccessibilityIdentifier
        self.arrowAccessibilityIdentifier = arrowAccessibilityIdentifier
        self.subsection = subsection
    }
}

public struct GenericCellModel: AccessibilityProtocol {
    let titleKey: String
    let tooltipInfo: (message: String, accessibilityIdentifier: String)?
    let valueInfo: (value: Any, accessibilityIdentifier: String)?
    let showDisclosureIndicator: Bool
    public let accessibilityIdentifier: String?
    
    public init(titleKey: String,
                tooltipInfo: (String, String)? = nil,
                valueInfo: (Any, String)? = nil,
                accessibilityIdentifier: String?,
                showDisclosureIndicator: Bool = true) {
        self.titleKey = titleKey
        self.tooltipInfo = tooltipInfo
        self.valueInfo = valueInfo
        self.showDisclosureIndicator = showDisclosureIndicator
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

protocol UserDataCellModelProtocol {
    var title: String { get }
    var accessibilityTitle: String { get }
    var description: String { get }
    var accessibilityDescription: String? { get }
    var accessibilityId: String { get }
    var accessibilityBtn: String? { get }
}

public enum UserDataEditableMode {
    case local
    case web
    case none
}

protocol UserDataEditableCellModelProtocol: UserDataCellModelProtocol {
    var editing: Bool { get set }
    var editAccessibilityId: String { get }
    var mode: UserDataEditableMode { get }
    var accessibilityBtn: String? { get }
}

struct UserDataEditableCellModel: UserDataEditableCellModelProtocol {
    var title: String
    var accessibilityTitle: String
    var description: String
    var accessibilityDescription: String?
    var accessibilityId: String
    var accessibilityBtn: String?
    var allowedCharacters: CharacterSet?
    var editing: Bool
    var editAccessibilityId: String
    var mode: UserDataEditableMode
}

struct UserDataCellModel: UserDataCellModelProtocol {
    var title: String
    var accessibilityTitle: String
    var description: String
    var accessibilityDescription: String?
    var accessibilityId: String
    var accessibilityBtn: String?
    
    init(title: String,
         accessibilityTitle: String,
         description: String,
         accessibilityDescription: String? = nil,
         accessibilityId: String,
         accessibilityBtn: String? = nil) {
        self.title = title
        self.accessibilityTitle = accessibilityTitle
        self.description = description
        self.accessibilityDescription = accessibilityDescription
        self.accessibilityId = accessibilityId
        self.accessibilityBtn = accessibilityBtn
    }
}
