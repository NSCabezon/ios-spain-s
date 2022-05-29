//
//  PermissionsPromptDialogsData.swift
//  PersonalArea
//
//  Created by Luis Escámez Sánchez on 26/11/2020.
//

import Foundation

public struct PromptDialogInfo {
    
    public let title: LocalizedStylableText?
    public let description: LocalizedStylableText?
    public let questionText: LocalizedStylableText?
    public let acceptButtonText: LocalizedStylableText?
    public let acceptAction: (() -> Void)?
    public let cancelButtonText: LocalizedStylableText?
    public let cancelAction: (() -> Void)?
    
    public init(title: LocalizedStylableText?,
                description: LocalizedStylableText?,
                questionText: LocalizedStylableText?,
                acceptButtonText: LocalizedStylableText?,
                acceptAction: (() -> Void)?,
                cancelButtonText: LocalizedStylableText?,
                cancelAction: (() -> Void)?) {
        self.title = title
        self.description = description
        self.questionText = questionText
        self.acceptButtonText = acceptButtonText
        self.acceptAction = acceptAction
        self.cancelButtonText = cancelButtonText
        self.cancelAction = cancelAction
    }
}

public struct PromptDialogInfoIdentifiers {
    public let title: String?
    public let body: String?
    public let question: String?
    public let acceptButton: String?
    public let cancelButton: String?
    
    public init(title: String?,
                body: String?,
                question: String?,
                acceptButton: String?,
                cancelButton: String?) {
        self.title = title
        self.body = body
        self.question = question
        self.acceptButton = acceptButton
        self.cancelButton = cancelButton
    }
}

public struct LocationPermissionsPromptDialogData {
    
    public static func getLocationDialogInfo(acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) -> PromptDialogInfo {
        return PromptDialogInfo(title: localized("permissionsAlert_title_publicLocation"),
                                description: localized("permissionsAlert_text_publicLocation"),
                                questionText: nil,
                                acceptButtonText: localized("generic_button_continue"),
                                acceptAction: acceptAction,
                                cancelButtonText: localized("generic_button_cancel"),
                                cancelAction: cancelAction)
    }
    
    public static func getLocationDialogIdentifiers() -> PromptDialogInfoIdentifiers {
        return PromptDialogInfoIdentifiers(title: "permissionsAlert_title_publicLocation",
                                           body: "permissionsAlert_text_publicLocation",
                                           question: nil,
                                           acceptButton: "generic_button_continue",
                                           cancelButton: "generic_button_cancel")
    }
}

public struct BiometryPermissionsPromptDialogData {
    
    public static func getBiometryDialogInfo(biometryType: BiometryTypeEntity,
                                             acceptAction: @escaping () -> Void,
                                             cancelAction: @escaping () -> Void) -> PromptDialogInfo {
        let biometryText = biometryType.biometryText
        
        return PromptDialogInfo(title: localized("security_alertTitle_touchID", [StringPlaceholder(.value, biometryText)]),
                                description: localized(getDescriptionKey(from: biometryType)),
                                questionText: localized("security_alertText_activateTouchId", [StringPlaceholder(.value, biometryText)]),
                                acceptButtonText: localized(acceptTitleFor(biometryType)),
                                acceptAction: acceptAction,
                                cancelButtonText: localized("generic_buttom_noThanks"),
                                cancelAction: cancelAction)
    }
    
    public static func getBiometryDialogIdentifiers() -> PromptDialogInfoIdentifiers {
        return PromptDialogInfoIdentifiers(title: "permissionsAlert_title_publicLocation",
                                           body: "permissionsAlert_text_publicLocation",
                                           question: "permissionsAlert_question_publicLocation",
                                           acceptButton: "generic_button_continue",
                                           cancelButton: "generic_button_cancel")
    }
    
    public static func getBiometryAlertMessage(for state: BiometryState,
                                               biometryType: BiometryTypeEntity) -> LocalizedStylableText {
        switch state {
        case .enabled:
            return localized("security_text_activateTouchId",
                             [StringPlaceholder(.value, biometryType.biometryText)])
        case .disabled:
            return localized("security_text_disableTouchId",
                             [StringPlaceholder(.value, biometryType.biometryText)])
        }
    }
    
    private static func getDescriptionKey(from biometryType: BiometryTypeEntity) -> String {
        switch biometryType {
        case .faceId:
            return "faceId_alert_rememberUser"
        case.touchId:
            return "personalArea_alert_touchid_widget"
        case .none:
            return "personalArea_alert_touchid_widget"
        case .error(biometry: _, error: _):
            return "personalArea_alert_touchid_widget"
        }
    }
    
    private static func getBiometrytext(from biometryType: BiometryTypeEntity) -> String {
        switch biometryType {
        case .touchId: return "Touch ID"
        case .faceId: return "Face ID"
        default: return ""
        }
    }
    
    private static func acceptTitleFor(_ biometryType: BiometryTypeEntity) -> String {
        switch biometryType {
        case .touchId: return "security_button_activateTouchId"
        case .faceId: return "security_button_activateFaceId"
        default: return ""
        }
    }
}

public enum BiometryState {
    case enabled
    case disabled
}
