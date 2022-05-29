//
//  SpainAccountHomeActionModifier.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 12/4/21.
//

import Foundation
import Account
import CoreFoundationLib
import Bizum

final class SpainAccountHomeActionModifier {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SpainAccountHomeActionModifier: AccountHomeActionModifierProtocol {    
    func getActionButtonFillViewType(for accountType: AccountActionType) -> ActionButtonFillViewType? {
        if case .custome(let identifier, _, _, _, _, _, _) = accountType, identifier == "bizum" {
            return .defaultWithBackground(
                DefaultActionButtonWithBackgroundViewModel(
                    title: localized("frequentOperative_button_bizum"),
                    imageKey: "icnBizumWhite",
                    renderingMode: .alwaysOriginal,
                    titleAccessibilityIdentifier: "frequentOperative_button_bizum",
                    imageAccessibilityIdentifier: "icnBizumWhite",
                    backgroundKey: "imgOperativeBgBizum",
                    accessibilityButtonValue: "voiceover_optionSendMoneyMobile"))
        } else {
            return nil
        }
    }
    
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity) {
        if case .custome(let identifier, _, _, _, _, _, _) = action, identifier == "bizum" {
            let coordinator: BizumStartCapable = dependenciesResolver.resolve(for: BizumStartCapable.self)
            coordinator.launchBizum()
        } else {
            self.dependenciesResolver.resolve(for: AccountsHomeCoordinatorDelegate.self)
                .didSelectAction(action: action, entity: entity)
        }
    }
}
