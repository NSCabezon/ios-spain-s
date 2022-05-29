//
//  PersonalAreaBiometryAction.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 22/4/21.
//

import PersonalArea
import CoreFoundationLib
import UI

public final class PersonalAreaBiometryAction {
    
    private let dependenciesResolver: DependenciesDefault
    private var reloadCompletion: ((Bool) -> Void)?

    private var useCaseHandler: UseCaseHandler {
        return dependenciesResolver.resolve()
    }
    lazy var quickBalanceConfigurator: QuickBalanceConfigurator = {
        return QuickBalanceConfigurator(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var biometryConfigurator: BiometryConfigurator = {
        return BiometryConfigurator(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var userTypeVerifierHelper: UserTypeVerifierHelper = {
        return UserTypeVerifierHelper(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var biometryViewHelper: BiometryViewHelper = {
        return BiometryViewHelper(dependenciesResolver: dependenciesResolver)
    }()
    lazy var quickBalanceViewHelper: QuickBalanceViewHelper = {
        return QuickBalanceViewHelper(view: self.dependenciesResolver.resolve(for: CoordinatorViewControllerProvider.self).viewController)
    }()

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = DependenciesDefault(father: dependenciesResolver)
    }
    
    public func didSelectBiometry(_ completion: @escaping (Bool) -> Void) {
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

extension PersonalAreaBiometryAction: QuickBalanceConfiguratorDelegate {

    func quickBalanceEnabled() {
        let message = localized("security_alert_activateTouchIdAndQuickBalance", [StringPlaceholder(.value, self.biometryConfigurator.getBiometryText())])
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    func enableQuickBalanceError() {
        self.reloadCompletion?(true)
    }
    
    func quickBalanceDisabled() {
        let message = localized("security_alert_disableTouchIdAndQuickBalance", [StringPlaceholder(.value, self.biometryConfigurator.getBiometryText())])
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    func disableQuickBalanceError() {
        self.reloadCompletion?(true)
    }

}

extension PersonalAreaBiometryAction: BiometryConfiguratorDelegate {
    public func errorInFootprintRegistration() {
        self.biometryViewHelper.showBiometryMessage(
            localizedKey: "_alert_errorActivation",
            biometryType: self.biometryConfigurator.getBiometryType()
        )
        self.reloadCompletion?(true)
    }
    
    public func biometryEnabled() {
        self.biometryViewHelper.showBiometryAlert(
            localizedKey: "security_text_activateTouchId",
            biometryText: self.biometryConfigurator.getBiometryText()
        )
        self.reloadCompletion?(true)
    }
    
    public func biometryDisabled() {
        self.quickBalanceConfigurator.isQuickBalanceEnabled { [weak self] isQuickBalanceEnabled in
            guard let strongSelf = self else { return }
            if isQuickBalanceEnabled {
                strongSelf.quickBalanceConfigurator.disableQuickBalance()
            } else {
                strongSelf.biometryViewHelper.showBiometryAlert(
                    localizedKey: "security_text_disableTouchId",
                    biometryText: strongSelf.biometryConfigurator.getBiometryText()
                )
                strongSelf.reloadCompletion?(true)
            }
        }
    }
}

extension PersonalAreaBiometryAction: UserTypeVerifierHelperDelegate {
    public func loginTypeUser() {
        var localizedKey = "security_alert_activateTouchId"
        if case .faceId = self.biometryConfigurator.getBiometryType() {
            localizedKey = "security_alert_activateFaceId"
        }
        let message: LocalizedStylableText = localized(localizedKey)
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    public func loginTypeNoUser() {
        self.biometryViewHelper.showConfigureBiometryDialog(
            biometryType: self.biometryConfigurator.getBiometryType(),
            acceptCompletion: self.biometryConfigurator.enableBiometry,
            cancelCompletion: self.reloadCompletion
        )
    }
}
