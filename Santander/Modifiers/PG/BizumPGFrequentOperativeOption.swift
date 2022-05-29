//
//  BizumPGFrequentOperativeOption.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 09/04/2021.
//

import CoreFoundationLib
import UI
import Bizum

final class BizumPGFrequentOperativeOption {
    let trackName: String? = "bizum"
    let rawValue: String = "bizum"
    let accessibilityIdentifier: String? = SpainAccessibilityPGFrequentOperatives.bizum
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumPGFrequentOperativeOption: PGFrequentOperativeOptionProtocol {
    func getAction() -> PGFrequentOperativeOptionAction {
        return .custom { [weak self] in
            self?.goToBizum()
        }
    }
    
    func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType {
        let button: ActionButtonFillViewType
        if isSmartGP {
            button = .defaultButton(DefaultActionButtonViewModel(
                title: "frequentOperative_button_bizum",
                imageKey: "icnBizum",
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: "icnBizum"
            ))
        } else {
            button = .defaultWithBackground(DefaultActionButtonWithBackgroundViewModel(
                                                title: "frequentOperative_button_bizum",
                                                imageKey: "icnBizumWhite",
                                                renderingMode: .alwaysOriginal,
                                                titleAccessibilityIdentifier: "",
                                                imageAccessibilityIdentifier: "icnBizumWhite",
                                                backgroundKey: "imgOperativeBgBizum",
                                                accessibilityButtonValue: "voiceover_optionSendMoneyMobile"))
        }
        return button
    }
    
    func getEnabled() -> PGFrequentOperativeOptionEnabled {
        return .custom(enabled: { return true })
    }
    
    func getLocation() -> String? {
        return nil
    }
}

private extension BizumPGFrequentOperativeOption {
    func goToBizum() {
        let coordinator: BizumStartCapable = dependenciesResolver.resolve(for: BizumStartCapable.self)
        coordinator.launchBizum()
    }
}
