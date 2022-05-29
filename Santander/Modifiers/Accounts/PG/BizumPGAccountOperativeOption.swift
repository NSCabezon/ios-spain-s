import CoreFoundationLib
import UI
import Bizum

final class BizumPGAccountOperativeOption {
    private let dependenciesResolver: DependenciesResolver
    let accessibilityIdentifier: String? = SpainAccessibilityPGAccountOperativeActionType.btnBizum
    let trackName: String? = "bizum"
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumPGAccountOperativeOption: AccountOperativeActionTypeProtocol {
    func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType {
        let button: ActionButtonFillViewType
        if isSmartGP {
            button = .defaultButton(DefaultActionButtonViewModel(
                title: self.values().title,
                imageKey: "icnBizum",
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: self.values().imageName,
                accessibilityButtonValue: "voiceover_optionSendMoneyMobile")
            )
        } else {
            button = .defaultWithBackground(DefaultActionButtonWithBackgroundViewModel(
                title: self.values().title,
                imageKey: "icnBizumWhite",
                renderingMode: .alwaysOriginal,
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: self.values().imageName,
                backgroundKey: "imgOperativeBgBizum",
                accessibilityButtonValue: "voiceover_optionSendMoneyMobile")
            )
        }
        return button
    }
    
    func getAction() -> AccountOperativeAction {
        return .custom { [weak self] in
            self?.goToBizum()
        }
    }
    
    func values() -> (title: String, imageName: String) {
        return ("accountOption_button_bizum", "icnBizum")
    }
    
    var rawValue: String {
        return "bizum"
    }
}

private extension BizumPGAccountOperativeOption {
    func goToBizum() {
        dependenciesResolver.resolve(for: BizumStartCapable.self).launchBizum()
    }
}
