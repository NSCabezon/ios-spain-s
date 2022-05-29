//
//  RequestMoneyPGAccountOperativeOption.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 21/4/21.
//

import CoreFoundationLib
import UI
import Bizum

final class RequestMoneyPGAccountOperativeOption: AccountOperativeActionTypeProtocol {
    private let dependenciesResolver: DependenciesResolver
    let accessibilityIdentifier: String? = SpainAccessibilityPGAccountOperativeActionType.btnRequestMoney
    let trackName: String? = "pedir_dinero"
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension RequestMoneyPGAccountOperativeOption {
    func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType {
        let values = self.values()
        return .defaultButton(DefaultActionButtonViewModel(title: values.title,
                                                           imageKey: values.imageName,
                                                           titleAccessibilityIdentifier: "",
                                                           imageAccessibilityIdentifier: values.imageName))
    }
    
    func getAction() -> AccountOperativeAction {
        return .custom { [weak self] in
            self?.goToBizum()
        }
    }
    
    func values() -> (title: String, imageName: String) {
        return ("accountOption_label_requestMoney", "icnRequestMoney")
    }
    
    var rawValue: String {
        return "bizum"
    }
}

private extension RequestMoneyPGAccountOperativeOption {
    func goToBizum() {
        dependenciesResolver.resolve(for: BizumStartCapable.self).launchBizum()
    }
}
