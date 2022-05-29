//
//  InboxHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 1/17/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import Inbox
import CoreFoundationLib

final class InboxHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    
}

extension InboxHomeCoordinatorNavigator: InboxHomeModuleCoordinatorDelegate {
    
    func didSelectOnlineInbox(_ configuration: WebViewConfiguration?) {
        guard let configuration = configuration else { return }
        
        let linkHandler = WebViewLinkHandlerFactory(
            configuration: configuration,
            dependencies: self.dependencies,
            errorHandler: self.errorHandler).getLinkHandler(of: .onlineMessages)
        
        let presenter = self.navigatorProvider.pushMailBoxNavigator.getPresenter(
            option: .onlineMessages(config: configuration, linkHandler: linkHandler))
        let mailBoxViewController = presenter.viewController
        if configuration.isFullScreen {
            mailBoxViewController.modalPresentationStyle = .fullScreen
            self.viewController?.navigationController?.present(mailBoxViewController, animated: true)
        } else {
            self.viewController?.navigationController?.pushViewController(mailBoxViewController, animated: true)
        }
    }
    
    func didSelectNotificationInbox() {
        //TODO: add notification navigation
    }
    
    func didSelectOffer(_ offer: OfferEntity?) {
        guard let offer = offer else { return }
        self.executeOffer(offer)
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
}
