//
//  PersonalAreaQuickBalanceAction.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 16/4/21.
//

import PersonalArea
import CoreFoundationLib
import UI

public final class PersonalAreaQuickBalanceAction {
    
    private let dependenciesResolver: DependenciesDefault
    private var reloadCompletion: ((Bool) -> Void)?
    private var wasBiometryEnabled: Bool = false

    private var localAuthPermissionManager: LocalAuthenticationPermissionsManagerProtocol {
        return self.dependenciesResolver.resolve()
    }
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve()
    }
    
    lazy var quickBalanceConfigurator: QuickBalanceConfigurator = {
        return QuickBalanceConfigurator(dependenciesResolver: dependenciesResolver, delegate: self)
    }()
    lazy var biometryConfigurator: BiometryConfigurator = {
        return BiometryConfigurator(dependenciesResolver: self.dependenciesResolver, delegate: self)
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
    
    public func didSelectQuickBalance(_ completion: @escaping (Bool) -> Void) {
        self.reloadCompletion = completion
        self.quickBalanceConfigurator.isQuickBalanceEnabled { [weak self] wasQuickBalanceEnabled in
            guard let strongSelf = self else {return}
            if wasQuickBalanceEnabled {
                strongSelf.quickBalanceConfigurator.disableQuickBalance()
            } else {
                if !strongSelf.biometryConfigurator.isBiometryAvailable() {
                    strongSelf.biometryViewHelper.showDisabledBiometryDialog(biometryType: strongSelf.biometryConfigurator.getBiometryType())
                } else {
                    // Storing biometry state in order to be used when enabling quickbalance
                    strongSelf.wasBiometryEnabled = strongSelf.biometryConfigurator.isBiometryEnabled()
                    if strongSelf.biometryConfigurator.isBiometryEnabled() {
                        strongSelf.quickBalanceConfigurator.enableQuickBalance()
                    } else {
                        strongSelf.userTypeVerifierHelper.askForUserLoginType()
                    }
                }
            }
        }
    }
}

private extension PersonalAreaQuickBalanceAction {
    var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
}

extension PersonalAreaQuickBalanceAction: QuickBalanceConfiguratorDelegate {
    func quickBalanceEnabled() {
        let message: LocalizedStylableText = self.wasBiometryEnabled ? localized("security_alert_activateQuickBalance") : localized("security_alert_activateTouchIdAndQuickBalance", [StringPlaceholder(.value, self.biometryConfigurator.getBiometryText())])
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    func enableQuickBalanceError() {
        self.reloadCompletion?(true)
    }
    
    func quickBalanceDisabled() {
        let message: LocalizedStylableText = localized("security_alert_disableQuickBalance")
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)
    }
    
    func disableQuickBalanceError() {
        self.reloadCompletion?(true)
    }
}

extension PersonalAreaQuickBalanceAction: BiometryConfiguratorDelegate {
    public func errorInFootprintRegistration() {
        self.biometryViewHelper.showBiometryMessage(localizedKey: "_alert_errorActivation", biometryType: self.biometryConfigurator.getBiometryType())
    }
    
    public func biometryEnabled() {
        self.quickBalanceConfigurator.enableQuickBalance()
    }
    
    public func biometryDisabled() {
        self.quickBalanceConfigurator.disableQuickBalance()
    }
}

extension PersonalAreaQuickBalanceAction: UserTypeVerifierHelperDelegate {
    public func loginTypeUser() {
        let message: LocalizedStylableText = localized("security_alert_activateQuickBalanceUser")
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: .message)
        self.reloadCompletion?(true)

    }
    
    public func loginTypeNoUser() {
        self.quickBalanceViewHelper.showQuickBalanceAlert(
            biometryType: self.biometryConfigurator.getBiometryType(),
            acceptAction: self.biometryConfigurator.enableBiometry,
            cancelAction: { [weak self] in
                self?.reloadCompletion?(true)
            }
        )
    }
}
