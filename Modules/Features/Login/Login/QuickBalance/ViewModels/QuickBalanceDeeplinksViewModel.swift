//
//  QuickBalanceDeeplinksViewModel.swift
//  Login
//
//  Created by Iván Estévez on 06/04/2020.
//

import Foundation
import CoreFoundationLib

struct QuickBalanceDeeplinksViewModel {
    let buttons: [QuickBalanceDeeplinkButtonModel]
}

struct QuickBalanceDeeplinkButtonModel: ActionButtonFillViewModelProtocol {
    let action: QuickBalanceAction
    let viewType: ActionButtonFillViewType
    
    init(action: QuickBalanceAction) {
        self.action = action
        self.viewType = action.getViewType() ?? ActionButtonFillViewType.offer(OfferImageViewActionButtonViewModel())
    }
}

enum QuickBalanceAction: String {
    case bizum = "bizum"
    case sendMoney = "thab"
    case cardPin = "tarpin"
    case cardTurnOff = "taroff"
    case securitySettings = "secset"
    
    public func values() -> (title: String, imageName: String)? {
        let values: [QuickBalanceAction: (String, String)] = [
            .bizum: ("toolbar_title_bizum", "icnBizum"),
            .sendMoney: ("frequentOperative_label_sendMoney", "icnSendMoney"),
            .cardPin: ("cardsOption_button_pin", "icnPin"),
            .cardTurnOff: ("cardsOption_button_turnOff", "icnOff")
        ]
        return values[self]
    }
    
    public func getViewType() -> ActionButtonFillViewType? {
        guard
            self != .securitySettings,
            let value = self.values()
            else { return nil }
        return .defaultButton(
            DefaultActionButtonViewModel(
                title: value.title,
                imageKey: value.imageName,
                titleAccessibilityIdentifier: "",
                imageAccessibilityIdentifier: value.imageName
            )
        )
    }
}

extension QuickBalanceAction: AccessibilityProtocol {
    var accessibilityIdentifier: String? {
        switch self {
        case .bizum:
            return AccessibilityQuickBalance.btnBizum.rawValue
        case .sendMoney:
            return AccessibilityQuickBalance.btnSendMoney.rawValue
        case .cardPin:
            return AccessibilityQuickBalance.btnPin.rawValue
        case .cardTurnOff:
            return AccessibilityQuickBalance.btnBlockCard.rawValue
        case .securitySettings:
            return AccessibilityQuickBalance.btnActivate.rawValue
        }
    }
}
