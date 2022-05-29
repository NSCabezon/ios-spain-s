//
//  BiometryViewHelper.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 23/4/21.
//

import Foundation

import CoreFoundationLib
import UI

public class BiometryViewHelper {
    var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
    private let dependenciesResolver: DependenciesDefault
    private var localAuthPermissionManager: LocalAuthenticationPermissionsManagerProtocol {
        return self.dependenciesResolver.resolve()
    }

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    public func showBiometryMessage(localizedKey: String, biometryType: BiometryTypeEntity) {
        var localizedKey = "touchId\(localizedKey)"
        if case .faceId = biometryType {
            localizedKey = "\(localizedKey.replace("touchId", "faceId").replace("TouchId", "FaceId"))"
        }
        personalAreaCoordinator.showBiometryMessage(localizedKey: localizedKey)
    }
    
    public func showBiometryAlert(localizedKey: String, biometryText: String) {
        let text: LocalizedStylableText = localized(localizedKey, [StringPlaceholder(.value, biometryText)])
        personalAreaCoordinator.showAlert(with: text, messageType: .info)
    }
    
    public func showDisabledBiometryDialog(biometryType: BiometryTypeEntity) {
        var errorTitle: LocalizedStylableText = .empty
        switch biometryType {
        case .faceId, .error(.faceId, _):
            errorTitle = localized("loginTouchId_alert_title_faceIdActivate")
        case .touchId, .error(.touchId, _):
            errorTitle = localized("loginTouchId_alert_title_digitalFingerprint")
        case .error, .none: break
        }
        self.personalAreaCoordinator.showAlertDialog(
            acceptTitle: localized("genericAlert_buttom_settings"),
            cancelTitle: localized("generic_button_cancel"),
            title: errorTitle,
            body: localized("personalArea_alert_text_widget"),
            acceptAction: { [weak self] () in
                guard let self = self else { return }
                self.personalAreaCoordinator.goToSettings()
            },
            cancelAction: nil)
    }
    
    public func showConfigureBiometryDialog(biometryType: BiometryTypeEntity, acceptCompletion: @escaping () -> Void, cancelCompletion: ((Bool) -> Void)?) {
        let cancelCompletion: () -> Void = {
            cancelCompletion?(true)
        }
        let info = BiometryPermissionsPromptDialogData.getBiometryDialogInfo(
            biometryType: biometryType,
            acceptAction: acceptCompletion,
            cancelAction: cancelCompletion
        )
        let identifiers = BiometryPermissionsPromptDialogData.getBiometryDialogIdentifiers()
        personalAreaCoordinator.showPromptDialog(
            info: info,
            identifiers: identifiers,
            closeButtonEnabled: false
        )
    }
}
