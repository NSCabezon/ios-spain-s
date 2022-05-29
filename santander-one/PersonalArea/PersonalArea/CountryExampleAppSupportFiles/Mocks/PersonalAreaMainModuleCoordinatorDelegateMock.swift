//
//  PersonalAreaMainModuleCoordinatorDelegateMock.swift
//  PersonalArea
//
//  Created by Juan Jose Acosta González on 9/9/21.
//

import CoreFoundationLib
import UI
import CoreDomain

final class PersonalAreaMainModuleCoordinatorDelegateMock: PersonalAreaMainModuleCoordinatorDelegate {
    func registerForDeeplink() {}
    func startCustomLoading(completion: (() -> Void)?) {}
    func didSelectOffer(offer: OfferRepresentable) {}
    func goToChangePassword() {}
    func goToSmartLock() {}
    func openAppStore(appId id: Int) {}
    func globalPositionDidReload() {}
    func performAvatarChange(cameraTitle: LocalizedStylableText, cameraRollTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cameraAction: (() -> Void)?, cameraRollAction: (() -> Void)?) {}
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cancelAction: (() -> Void)?) {}
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {}
    func showSecureDeviceOperative() {}
    func didSelectUserOperativity() {}
    func didSelectAccessKey() {}
    func didSelectMultichannelSignature() {}
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, source: UIViewController?, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {}
    func showSecureDeviceOperative(device: OTPPushDeviceEntity?) {}
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {}
    func reloadGlobalPosition() {}
    func showLoading(completion: (() -> Void)?) {}
    func hideLoading(completion: (() -> Void)?) {}
    func setTouchIdLoginData(deviceMagicPhrase deviceToken: String?, touchIDLoginEnabled: Bool?, completion: @escaping (Bool) -> Void) {}
    func goToSettings() {}
    func showBiometryMessage(localizedKey: String) {}
    func performFootprintRegistration(completion: ((Bool) -> Void)?) {}
    func startGlobalLoading(completion: (() -> Void)?) {}
    func didSelectOffer(offer: OfferEntity, in location: PullOfferLocation) {}
    func didChangeLanguage(language: Language) {}
    func performAvatarChange(cameraTitle: LocalizedStylableText, cameraRollTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, source: UIViewController, cameraAction: (() -> Void)?, cameraRollAction: (() -> Void)?) { }
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, source: UIViewController, cancelAction:(() -> Void)?) {}
    func didSelectDismiss() {}
    func didSelectMenu() {}
    func didSelectSearch() {}
    func didChangeLanguage(_ language: LanguageType) { }
    func navigateToSettings() { }
    func showPromptDialog(info: PromptDialogInfo, identifiers: PromptDialogInfoIdentifiers, closeButtonEnabled: Bool) {}
    func showAlert(with message: LocalizedStylableText, messageType: TopAlertType) {}
    func goToBizum() {}
    func goToAddToApplePay() {}
    func openAppStore() {}
}
