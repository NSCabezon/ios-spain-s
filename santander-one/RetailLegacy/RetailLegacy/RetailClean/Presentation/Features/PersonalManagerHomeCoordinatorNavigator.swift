//
//  PersonalManagerHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by alvola on 03/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import PersonalManager
import UI
import CoreFoundationLib
import Operative

final class PersonalManagerHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    private let storeProductViewControllerDelegate = StoreProductViewControllerDelegate()
}

protocol PersonalManagerHandleOpinatorDelegate: class {
    func handleOpinator(_ opinator: OpinatorInfoRepresentable)
}

extension PersonalManagerHomeCoordinatorNavigator: PersonalManagerMainModuleCoordinatorDelegate {
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        var error: LocalizedStylableText = .empty
        var titleError: LocalizedStylableText = .empty
        
        if let title = title {
            titleError = title
        }
        if let body = body {
            error = body
        }
        guard !error.text.isEmpty else {
            return self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
        }
        
        guard let viewController = self.viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle ?? localized("generic_button_accept"), does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, showsCloseButton: showsCloseButton, source: viewController)
    }
    
    func showLoading(completion: (() -> Void)?) {
        startOperativeLoading { completion?() }
    }
    func hideLoading(completion: (() -> Void)?) { hideAllLoadings(completion: completion) }
    func didSelectDismiss() { viewController?.navigationController?.popViewController(animated: true) }
    func didSelectMenu() { drawer?.toggleSideMenu() }
    func didSelectSearch() { navigatorProvider.privateHomeNavigator.goToGlobalSearch() }
    func canOpenUrl(_ url: String) -> Bool {
        guard let url = URL(string: url), UIApplication.shared.canOpenURL(url) else { return false }
        return true
    }
    
    func open(url: String) {
        navigatorProvider.privateHomeNavigator.open(url: url)
    }
    
    func openAppStore() {
        guard let appStoreUsecase = self.dependenciesResolver.resolve(forOptionalType: AppStoreInformationUseCase.self) else { return }
        Scenario(useCase: appStoreUsecase).execute(on: self.useCaseHandler).onSuccess { [weak self] info in
            self?.storeProductViewControllerDelegate.openAppStore(id: info.storeId)
        }
    }
    
    func openChatWith(configuration: WebViewConfiguration) {
        navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandlerType: .managerWall, dependencies: dependencies, errorHandler: errorHandler, didCloseClosure: nil)
    }
    
    func didSelectOffer(offer: OfferEntity) {
        executeOffer(offer)
    }
}
