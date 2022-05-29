//
//  PersonalAreaBiometryAction.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 22/4/21.
//

import CoreFoundationLib
import UI

final class PersonalAreaBiometryAction {
    private let dependenciesResolver: DependenciesDefault
    private var reloadCompletion: ((Bool) -> Void)?
    
    private var useCaseHandler: UseCaseHandler {
        return dependenciesResolver.resolve()
    }
    lazy var biometryConfigurator: BiometryConfigurator = {
        return BiometryConfigurator(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var userTypeVerifierHelper: UserTypeVerifierHelper = {
        return UserTypeVerifierHelper(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var biometryViewHelper: BiometryViewHelper = {
        return BiometryViewHelper(dependenciesResolver: dependenciesResolver)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    func didSelectBiometry(_ completion: @escaping (Bool) -> Void) {
        self.reloadCompletion = completion
        if self.biometryConfigurator.isBiometryAvailable() {
            let wasBiometryEnabled = self.biometryConfigurator.isBiometryEnabled()
            if wasBiometryEnabled {
                self.biometryConfigurator.disableBiometry()
            } else {
                self.userTypeVerifierHelper.askForUserLoginType()
            }
        } else {
            self.biometryViewHelper.showDisabledBiometryDialog(biometryType: self.biometryConfigurator.getBiometryType())
        }
    }
}

private extension PersonalAreaBiometryAction {
    var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
}

extension PersonalAreaBiometryAction: BiometryConfiguratorDelegate {
    func errorInFootprintRegistration() {
        self.biometryViewHelper.showBiometryMessage(
            localizedKey: "_alert_errorActivation",
            biometryType: self.biometryConfigurator.getBiometryType()
        )
        self.reloadCompletion?(true)
    }
    
    func biometryEnabled() {
        self.biometryViewHelper.showBiometryAlert(
            localizedKey: "security_text_activateTouchId",
            biometryText: self.biometryConfigurator.getBiometryText()
        )
        self.reloadCompletion?(true)
    }
    
    func biometryDisabled() {
        self.biometryViewHelper.showBiometryAlert(
            localizedKey: "security_text_disableTouchId",
            biometryText: self.biometryConfigurator.getBiometryText()
        )
        self.reloadCompletion?(true)
    }
}

extension PersonalAreaBiometryAction: UserTypeVerifierHelperDelegate {
    func loginTypeUser() {
        var localizedKey = "security_alert_activateTouchId"
        if case .faceId = self.biometryConfigurator.getBiometryType() {
            localizedKey = "security_alert_activateFaceId"
        }
        let message: LocalizedStylableText = localized(localizedKey)
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    func loginTypeNoUser() {
        self.biometryViewHelper.showConfigureBiometryDialog(
            biometryType: self.biometryConfigurator.getBiometryType(),
            acceptCompletion: self.biometryConfigurator.enableBiometry,
            cancelCompletion: self.reloadCompletion
        )
    }
}
