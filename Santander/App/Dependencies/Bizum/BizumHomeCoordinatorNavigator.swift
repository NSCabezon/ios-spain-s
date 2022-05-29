//
//  BizumHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Carlos Gutiérrez Casado on 09/09/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import Operative
import GlobalPosition
import RetailLegacy
import Bizum
import UI

final class BizumHomeCoordinatorNavigator {
    private var drawer: BaseMenuViewController
    private let dependenciesEngine: DependenciesResolver
    
    required init(drawer: BaseMenuViewController, dependenciesEngine: DependenciesResolver) {
        self.dependenciesEngine = dependenciesEngine
        self.drawer = drawer
    }
}

private extension BizumHomeCoordinatorNavigator {
    var baseWebNavigatable: BaseWebViewNavigatableLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    var offerCoordinatorLauncher: OfferCoordinatorLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    var viewController: UIViewController? {
        return (self.drawer.currentRootViewController as? UINavigationController)?.topViewController ?? self.drawer.currentRootViewController
    }
    
    var privateHomeNavigatorLauncher: PrivateHomeNavigatorLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    var operativeCoordinatorLauncher: OperativeCoordinatorLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    var virtualAssistantCoordinatorLauncher: VirtualAssistantCoordinatorLauncher {
        return self.dependenciesEngine.resolve()
    }
    
    func closeModalViewControllers(_ completion: (() -> Void)? = nil ) {
        guard let presendedController = self.viewController?.navigationController?.presentedViewController else {
            completion?()
            return
        }
        presendedController.dismiss(animated: true, completion: completion)
    }
}

extension BizumHomeCoordinatorNavigator: BizumHomeModuleCoordinatorDelegate {
    
    func didSelectDismiss() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        self.drawer.toggleSideMenu()
    }
    
    func goToBizumSendMoney(_ contacts: [BizumContactEntity]?) {
        self.goToBizumSendMoney(contacts, sendMoney: nil, handler: self)
    }

    func goToAmountSendMoney(_ contact: BizumContactEntity) {
        self.goToAmountSendMoney(contact, handler: self)
    }
    
    func goToBizumRequestMoney(_ contacts: [BizumContactEntity]?) {
        self.goToBizumRequestMoney(contacts, sendMoney: nil, handler: self)
    }
    
    func goToBizumCancel(_ operationEntity: BizumHistoricOperationEntity) {
        self.goToBizumCancel(operationEntity, handler: self)
    }
    
    func goToBizumAcceptRequestMoney(_ operation: BizumHistoricOperationEntity) {
        self.goToBizumAcceptMoneyRequest(operation, handler: self)
    }
    
    func goToBizumRefundMoney(operation: BizumHistoricOperationEntity) {
        self.showBizumRefundMoney(operation: operation, handler: self)
    }
    
    func goToVirtualAssistant() {
        self.virtualAssistantCoordinatorLauncher.goToVirtualAssistant()
    }

    func goToReuseSendMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney) {
        self.goToBizumSendMoney([contact], sendMoney: bizumSendMoney, handler: self)
    }

    func goToReuseRequestMoney(_ contact: BizumContactEntity, bizumSendMoney: BizumSendMoney) {
        self.goToBizumRequestMoney([contact], sendMoney: bizumSendMoney, handler: self)
    }
    
    func goToBizumCancelRequest(_ operation: BizumHistoricOperationEntity) {
        self.showBizumCancelRequest(operation: operation, handler: self)
    }
    
    func goToBizumRejectRequest(_ operation: BizumHistoricOperationEntity) {
        self.showBizumRejectRequest(operation: operation, handler: self)
    }
    
    func goToBizumRejectSend(_ operation: BizumHistoricOperationEntity) {
        self.showBizumRejectRequest(operation: operation, handler: self)
    }
    
    func goToBizumSplitExpenses(_ operation: SplitableExpenseProtocol) {
        self.goToBizumSplitExpenses(operation, handler: self)
    }
    
    func didSelectOffer(offer: OfferEntity) {
        self.offerCoordinatorLauncher.executeOffer(offer)
    }

    func goToBizumDonations() {
        self.goToBizumDonation(handler: self)
    }
    
    func didSelectSearch() {
        self.privateHomeNavigatorLauncher.goToGlobalSearch()
    }
}

extension BizumHomeCoordinatorNavigator: BizumLauncher, BizumLauncherDelegate, BizumSendMoneyLauncher, BizumRequestMoneyLauncher, BizumAcceptMoneyRequestOperativeLauncher, BizumRefundMoneyOperativeLauncher, BizumCancelLauncher, BizumCancelRequestOperativeLauncher, BizumRejectRequestOperativeLauncher, BizumSplitExpensesOperativeLauncher, BizumDonationOperativeLauncher {
    
    var dependencies: DependenciesResolver {
        return self.dependenciesEngine
    }
    
    var baseWebLauncher: BaseWebViewNavigatableLauncher {
        return self.baseWebNavigatable
    }
    
    func goToBizumWeb(configuration: WebViewConfiguration) {
        self.baseWebLauncher.goToWebView(configuration: configuration, type: .bizum, didCloseClosure: nil)
    }
    
    func startLoading() {
        self.showLoading()
    }
    
    func endLoading(completion: (() -> Void)?) {
        self.dismissLoading(completion: completion)
    }
    
    func showError() {
        let acceptAction = DialogButtonComponents(titled: localized("generic_button_accept"), does: nil)
        self.showOldDialog(title: nil,
                           description: localized("deeplink_alert_errorBizum"),
                           acceptAction: acceptAction,
                           cancelAction: nil,
                           isCloseOptionAvailable: true)
    }
    
    var bizumModifier: BizumModifierProtocol {
        self.dependenciesEngine.resolve(for: BizumModifierProtocol.self)
//        guard let modifier = self.dependenciesEngine.resolve(forOptionalType: BizumModifierProtocol.self) else {
//            return
//        }
//        return modifier
    }
}

extension BizumHomeCoordinatorNavigator: OperativeLauncherHandler {
    var operativeNavigationController: UINavigationController? {
        return self.viewController?.presentedViewController as? UINavigationController ?? self.viewController?.navigationController
    }
    
    var dependenciesResolver: DependenciesResolver {
        return self.dependenciesEngine
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        self.operativeCoordinatorLauncher.showOperativeLoading(completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        self.operativeCoordinatorLauncher.hideOperativeLoading(completion: completion)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        self.operativeCoordinatorLauncher.showOperativeAlertError(keyTitle: keyTitle, keyDesc: keyDesc, completion: completion)
    }
}

extension BizumHomeCoordinatorNavigator: BizumStartCapable {
    func launchBizum() {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.goToBizum(delegate: self)
        }
    }
}

extension BizumHomeCoordinatorNavigator: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self.viewController ?? UIViewController()
    }
}

extension BizumHomeCoordinatorNavigator: OldDialogViewPresentationCapable {
    var associatedOldDialogView: UIViewController {
        return self.viewController ?? UIViewController()
    }
    
    var associatedGenericErrorDialogView: UIViewController {
        return self.viewController ?? UIViewController()
    }
}

extension BizumHomeCoordinatorNavigator: SplitExpensesCoordinatorLauncher {
    func showSplitExpenses(_ operation: SplitableExpenseProtocol) {
        self.goToBizumSplitExpenses(operation)
    }
}
