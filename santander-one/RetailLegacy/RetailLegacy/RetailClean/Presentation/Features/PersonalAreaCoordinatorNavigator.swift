//
//  PersonalAreaCoordinatorNavigator.swift
//  RetailClean
//
//  Created by alvola on 20/11/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import Foundation
import PersonalArea
import UI
import CoreFoundationLib
import Cards
import CoreDomain

final class PersonalAreaCoordinatorNavigator: ModuleCoordinatorNavigator, SystemSettingsNavigatable {
    private lazy var storeProductViewControllerDelegate = StoreProductViewControllerDelegate()
    private lazy var sessionDataManager: SessionDataManager = {
        let manager = DefaultSessionDataManager(dependenciesResolver: dependencies.useCaseProvider.dependenciesResolver)
        manager.setDataManagerProcessDelegate(self)
        return manager
    }()
}

extension PersonalAreaCoordinatorNavigator: PersonalAreaMainModuleCoordinatorDelegate {
    
    func showSecureDeviceOperative() {
        self.launchOtpPushOperative(delegate: self)
    }
    
    func showSecureDeviceOperative(device: OTPPushDeviceEntity?) {
        if let device = device {
            self.launchOtpPushOperative(device: OTPPushDevice(deviceEntity: device), withDelegate: self)
        } else {
            self.launchOtpPushOperative(device: nil, withDelegate: self)
        }
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectSearch() {
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText? = nil, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        guard let viewController = viewController else { return }
        guard !body.text.isEmpty else {
            return showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
        }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: title, body: body, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: viewController)
    }
    
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonEnabled: Bool) {
        guard let viewController = viewController else { return }
        let builder = PromptDialogBuilder(info: info, identifiers: identifiers)
        LisboaDialog(
            items: builder.build(),
            closeButtonAvailable: closeButtonEnabled
        ).showIn(viewController)
    }
    
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {
        TopAlertController.setup(TopAlertView.self).showAlert(message, alertType: messageType, duration: 4.0)
    }
    
    func goToSettings() {
        self.navigateToSettings()
    }
    
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText? = nil, body: LocalizedStylableText, cancelAction: (() -> Void)?) {
        let buttonAction: (() -> Void)?  = { [weak self] in self?.navigateToSettings() }
        guard let viewController = viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: buttonAction)
        let cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        Dialog.alert(title: nil, body: body, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: viewController)
    }
    
    func performAvatarChange(cameraTitle: LocalizedStylableText, cameraRollTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cameraAction: (() -> Void)?, cameraRollAction: (() -> Void)?) {
        guard let viewController = viewController else { return }
        let libraryAction = LisboaDialogAction(
            title: cameraRollTitle,
            type: .white,
            margins: (left: 16, right: 16),
            action: {
                cameraRollAction?()
            }
        )
        let cameraAction = LisboaDialogAction(
            title: cameraTitle,
            type: .custom(backgroundColor: .santanderRed, titleColor: .white, font: .santander(family: .text, type: .bold, size: 16.0)),
            margins: (left: 16, right: 16),
            action: {
                cameraAction?()
            }
        )
        let horizontalActions = HorizontalLisboaDialogActions(left: libraryAction, right: cameraAction)
        let builder = LisboaDialog(
            items: [
                .margin(5.0),
                .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_title_select"),
                                                 font: .santander(family: .headline, type: .regular, size: 22.0),
                                                 color: UIColor.Legacy.uiBlack,
                                                 alignament: .center,
                                                 margins: (15, 15))),
                .margin(8.0),
                .styledText(LisboaDialogTextItem(text: localized("customizeAvatar_popup_text_select"),
                                                 font: .santander(family: .text, type: .regular, size: 16.0),
                                                 color: UIColor.Legacy.lisboaGrayNew,
                                                 alignament: .center,
                                                 margins: (15, 15))),
                .margin(8.0),
                .horizontalActions(horizontalActions)
            ],
            closeButtonAvailable: true
        )
        builder.showIn(viewController)
    }
    
    func didChangeLanguage(language: Language) {
        self.dependencies.localeManager.updateCurrentLanguage(language: language)
        startGlobalLoading(completion: { [weak self] in
            self?.globalPositionDidReload()
        })
    }
    
    func globalPositionDidReload() {
        loadPublicFiles()
    }
    
    func showLoading(completion: (() -> Void)?) {
        startOperativeLoading {
            completion?()
        }
    }
    
    func hideLoading(completion: (() -> Void)?) {
        hideAllLoadings(completion: completion)
    }
    
    func didSelectOffer(offer: OfferRepresentable) {
        self.executeOffer(action: offer.action, offerId: offer.id, location: offer.pullOfferLocation)
    }
    
    func didSelectMultichannelSignature() {
        self.goToSignature()
    }
    
    func openAppStore() {
        guard let appStoreUsecase = self.dependenciesResolver.resolve(forOptionalType: AppStoreInformationUseCase.self) else { return }
        Scenario(useCase: appStoreUsecase).execute(on: self.useCaseHandler).onSuccess { [weak self] info in
            self?.storeProductViewControllerDelegate.openAppStore(id: info.storeId)
        }
    }
    
    func goToAddToApplePay() {
        self.dependencies.deepLinkManager.registerDeepLink(DeepLink.addToApplePay)
    }
}

private extension PersonalAreaCoordinatorNavigator {
    func handleLoadSessionDataSuccess() {
        sessionManager.sessionStarted { [weak self] in
            guard let strongSelf = self else { return }
            let useCase = strongSelf.dependencies.useCaseProvider.getUserPreferencesEntityUseCase()
            UseCaseWrapper(
                with: useCase,
                useCaseHandler: strongSelf.dependencies.useCaseHandler,
                errorHandler: strongSelf.errorHandler,
                onSuccess: { [weak self] result in
                    strongSelf.hideAllLoadings { [weak self] in
                        let globalPositionOption = result.userPref?.globalPositionOnboardingSelected() ?? .classic
                        self?.dependencies.globalPositionReloadEngine.globalPositionDidReload()
                        self?.dependencies.navigatorProvider.personalAreaNavigator.goToPrivate(globalPositionOption: globalPositionOption)
                    }
                }, onError: { [weak self] _ in
                    self?.hideLoading(completion: nil)
                })
        }
    }
    
    func handleLoadSessionError(error: LoadSessionError) {
        UseCaseWrapper(with: useCaseProvider.getCheckPersistedUserUseCase(), useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.showError(error: error)
            }, onError: { [weak self] (_) in
                guard let strongSelf = self else { return }
                strongSelf.showError(error: error)
        })
    }
    
    func loadPublicFiles() {
        dependencies.publicFilesManager.loadPublicFiles(
            addingSubscriptor: PersonalAreaCoordinatorNavigator.self,
            withStrategy: .reload,
            timeout: 5
        ) { [weak self] in
            self?.publicFilesLoadingDidFinish()
            self?.dependencies.publicFilesManager.remove(subscriptor: PersonalAreaCoordinatorNavigator.self)
        }
    }
    
    func showError(error: LoadSessionError) {
        hideAllLoadings(completion: {
            switch error {
            case .generic, .intern:
                self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
            case .other(let errorMessage):
                self.showAlertError(keyTitle: nil, keyDesc: errorMessage, completion: nil)
            default:
                break
            }
        })
    }
}

// MARK: - OperativeNavigation

extension PersonalAreaCoordinatorNavigator: CardOnOffOperativeLauncher {
    
    var cardExternalDependencies: CardExternalDependenciesResolver {
        return dependencies.navigatorProvider.cardExternalDependenciesResolver
    }
    
    func goToSmartLock() {
        goToCardOnOff(card: nil, option: .turnOff, handler: self)
    }
}

// MARK: - Biometry

extension PersonalAreaCoordinatorNavigator {
    func setTouchIdLoginData(deviceMagicPhrase: String?, touchIDLoginEnabled: Bool?, completion: @escaping (Bool) -> Void) {
        startGlobalLoading(completion: {
            UseCaseWrapper(with: self.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: deviceMagicPhrase, touchIDLoginEnabled: touchIDLoginEnabled)), useCaseHandler: self.useCaseHandler, errorHandler: self.genericErrorHandler, onSuccess: { [weak self] (_) in
                
                guard let strongSelf = self else { return }
                strongSelf.hideAllLoadings {
                    strongSelf.deleteSiriIntents()
                    completion(true)
                }
                }, onError: { [weak self] (_) in
                    guard let strongSelf = self else { return }
                    strongSelf.hideAllLoadings {
                        completion(false)
                    }
            })
        })
    }
    
    func showBiometryMessage(localizedKey: String) {
        showDialogError(key: localizedKey)
    }
    
    func performFootprintRegistration(completion: ((Bool) -> Void)? = nil) {
        startGlobalLoading(completion: {
            UseCaseWrapper(with: self.useCaseProvider.registerDevice(input: RegisterDeviceInput(footPrint: UIDevice.current.getFootPrint(), deviceName: UIDevice.current.getDeviceName())), useCaseHandler: self.useCaseHandler, errorHandler: self.genericErrorHandler, onSuccess: { [weak self] (result) in
                guard let self = self else { return }
                
                UseCaseWrapper(with: self.useCaseProvider.setTouchIdLoginData(input: SetTouchIdLoginDataInput(deviceMagicPhrase: result.deviceMagicPhrase, touchIDLoginEnabled: result.touchIDLoginEnabled)), useCaseHandler: self.useCaseHandler, errorHandler: self.genericErrorHandler, onSuccess: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.hideAllLoadings {
                        strongSelf.donateSiriIntents()
                        completion?(true)
                    }
                    }, onError: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        strongSelf.hideAllLoadings {
                            completion?(false)
                        }
                })
                }, onGenericErrorType: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.hideAllLoadings {
                        completion?(false)
                    }
            })
        })
    }
}

extension PersonalAreaCoordinatorNavigator: SiriIntentsOperator {}

// MARK: - SessionProcessHelperDelegate
extension PersonalAreaCoordinatorNavigator: SessionDataManagerProcessDelegate {
    func handleProcessEvent(_ event: SessionProcessEvent) {
        switch event {
        case .fail(let error):
            handleLoadSessionError(error: error)
        case .loadDataSuccess:
            handleLoadSessionDataSuccess()
        case .updateLoadingMessage:
            break
        case .cancelByUser:
            break
        }
    }
}

// MARK: - EnableOtpPushOperativeLauncher

extension PersonalAreaCoordinatorNavigator: EnableOtpPushOperativeLauncher {}

extension PersonalAreaCoordinatorNavigator: SecurityAreaCoordinatorDelegate {
    
    func didSelectCallPhoneNumber(_ phoneNumber: String) {
        let numberToCall = phoneNumber.filterValidCharacters(characterSet: .decimalDigits)
        
        guard !numberToCall.isEmpty,
            let callUrl = URL(string: String(format: "tel://%@", numberToCall)) else { return }
        UIApplication.shared.open(callUrl)
    }
    
    func didSelectAction(_ action: SecurityActionType) {
        switch action {
        case .changePassword:
            self.goToChangePassword()
        case .changeSignature:
            self.goToSignature()
        default:
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectPermission() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func didSelectProtection() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func didSelectOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        self.executeOffer(offer)
    }
    
    internal func goToChangePassword() {
        self.goToChangePassword(handler: self)
    }
}

// MARK: - PublicFilesSubscriptor

extension PersonalAreaCoordinatorNavigator {
    func publicFilesLoadingDidFinish() {
        sessionDataManager.load()
    }
}

extension PersonalAreaCoordinatorNavigator: TripListCoordinatorDelegate {
    func didSelectAtm() {
        navigatorProvider.privateHomeNavigator.goToATMLocator(keepingNavigation: true)
    }
}

extension PersonalAreaCoordinatorNavigator: NoTripCoordinatorDelegate {}

// MARK: - SignatureLauncherDelegate

extension PersonalAreaCoordinatorNavigator: SignatureLauncher {
    var signatureLauncherNavigator: OperativesNavigatorProtocol {
        return self.navigator
    }

    func showError(keyDesc: String?) {
        self.showAlertError(keyTitle: nil, keyDesc: keyDesc, completion: nil)
    }
}

extension PersonalAreaCoordinatorNavigator: ChangePasswordLauncher {}
