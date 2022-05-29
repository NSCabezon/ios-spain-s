//
//  InboxActionBuilder.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/16/20.
//

import Foundation
import CoreFoundationLib

final class InboxActionBuilder {
    private var inboxActions: [InboxActionViewModel] = []
    private let isWebViewConfiguration: Bool
    weak var delegate: InboxActionDelegate?
    private let dependenciesResolver: DependenciesResolver
    
    init(isWebViewConfiguration: Bool, delegate: InboxActionDelegate?, dependenciesResolver: DependenciesResolver) {
        self.isWebViewConfiguration = isWebViewConfiguration
        self.delegate = delegate
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addOnlineInbox(_ offer: OfferEntity?) -> Self {
        if self.isWebViewConfiguration {
            let viewModel = InboxActionViewModel(
                imageName: "icnEmail",
                title: localized("mailbox_title_onlineMail"),
                description: localized("mailbox_text_onlineMail"),
                extras: InboxActionExtras(action: ()),
                accessibilityIdentifier: AccesibilityInbox.messages,
                action: delegate?.didSelectWebAction
            )
            self.inboxActions.append(viewModel)
        } else if let offer = offer {
            let viewModel = InboxActionViewModel(
                imageName: "icnEmail",
                title: localized("mailbox_title_onlineMail"),
                description: localized("mailbox_text_onlineMail"),
                extras: InboxActionExtras(offer: offer),
                accessibilityIdentifier: AccesibilityInbox.messages,
                offerAction: delegate?.didSelectOffer
            )
            self.inboxActions.append(viewModel)
        }
        return self
    }
    
    func addPrivateBankStatement(_ offer: OfferEntity?) -> Self {
        guard offer != nil else { return self }
        let viewModel = InboxActionViewModel(
            imageName: "icnExcerpts",
            title: localized("mailbox_title_privateBankExcerpts"),
            description: localized("mailbox_text_privateBankExcerpts"),
            extras: InboxActionExtras(offer: offer),
            accessibilityIdentifier: AccesibilityInbox.privateBankExcerpts,
            offerAction: delegate?.didSelectOffer
        )
        self.inboxActions.append(viewModel)
        return self
    }
    
    func addInboxSetup(_ offer: OfferEntity?) -> Self {
        let viewModel = InboxActionViewModel(
            imageName: "icnNotification",
            title: localized("mailbox_title_notification"),
            description: localized("mailbox_text_notification"),
            notificationAlert: offer != nil ? localized("mailbox_link_settingAlert") : nil,
            extras: InboxActionExtras(offer: offer),
            accessibilityIdentifier: AccesibilityInbox.notifications,
            action: delegate?.gotoInboxNotification,
            offerAction: delegate?.didSelectOffer
        )
        self.inboxActions.append(viewModel)
        return self
    }
    
    func addContract(_ offer: OfferEntity?,
                     _ solicitude: PendingSolicitudeInboxViewModel?) -> Self {
        guard offer != nil else { return self}
        let viewModel = InboxActionViewModel(
            imageName: "icnContractMailbox",
            title: localized("mailbox_title_contractMailbox"),
            description: localized("mailbox_text_contractMailbox"),
            extras: InboxActionExtras(pendingSolicitude: solicitude, offer: offer),
            accessibilityIdentifier: AccesibilityInbox.contract,
            offerAction: delegate?.didSelectSlideOffer
        )
        self.inboxActions.append(viewModel)
        return self
    }
    
    func addPersonalDocument(showDocumentation: Bool, offer: OfferEntity?) -> Self {
        guard offer != nil else { return self}
        if showDocumentation == true {
            let viewModel = InboxActionViewModel(
                imageName: "icnPersonalDoc",
                title: localized("mailbox_title_Document"),
                description: localized("mailbox_text_Document"),
                extras: InboxActionExtras(offer: offer),
                accessibilityIdentifier: AccesibilityInbox.documentation,
                offerAction: delegate?.didSelectOffer
            )
            self.inboxActions.append(viewModel)
        }
        return self
    }
    
    func addFioc(_ offer: OfferEntity?) -> Self {
        guard offer != nil else { return self }
        let viewModel = InboxActionViewModel(
            imageName: "icnForm",
            title: localized("mailbox_title_fioc"),
            description: localized("mailbox_text_fioc"),
            extras: InboxActionExtras(offer: offer),
            accessibilityIdentifier: AccesibilityInbox.fioc,
            offerAction: delegate?.didSelectOffer
        )
        self.inboxActions.append(viewModel)
        return self
    }

    func addSantanderKey(isEnabled: Bool) -> Self {
        guard let modifier = dependenciesResolver.resolve(forOptionalType: InboxActionBuilderModifierProtocol.self),
              isEnabled else { return self }
        let viewModel = modifier.addCustomAction()
        self.inboxActions.append(viewModel)
        return self
    }
    
    func build() -> [InboxActionViewModel] {
        return inboxActions
    }
}
