//
//  InboxActionBuilderModifier.swift
//  Santander
//
//  Created by Carlos Monfort Gómez on 24/5/21.
//

import Foundation
import CoreFoundationLib
import Ecommerce
import Inbox

final class InboxActionBuilderModifier {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension InboxActionBuilderModifier: InboxActionBuilderModifierProtocol {
    func addCustomAction() -> InboxActionViewModel {
        let viewModel = InboxActionViewModel(
            imageName: "icnSantanderLock",
            title: localized("mailbox_title_santanderKey"),
            description: localized("mailbox_text_santanderKey"),
            notificationAlert: localized("mailbox_link_pendingPurchases"),
            extras: InboxActionExtras(action: ()),
            accessibilityIdentifier: AccesibilityInbox.santanderKey,
            actionType: .custom(InboxAction.ecommerce)
        )
        return viewModel
    }
}

extension InboxActionBuilderModifier: InboxHomeCoordinatorDelegate {
    func didSelectAction(type: InboxActionType) {
        guard case let .custom(action) = type, let actionInbox = action as? InboxAction else { return }
        switch actionInbox {
        case .ecommerce:
            self.showEcommerce()
        }
    }
}

private extension InboxActionBuilderModifier {
    func showEcommerce() {
        let ecommerceNavigator = self.dependenciesResolver.resolve(for: EcommerceNavigatorProtocol.self)
        ecommerceNavigator.showEcommerce(.mainPushNotification)
    }
}
