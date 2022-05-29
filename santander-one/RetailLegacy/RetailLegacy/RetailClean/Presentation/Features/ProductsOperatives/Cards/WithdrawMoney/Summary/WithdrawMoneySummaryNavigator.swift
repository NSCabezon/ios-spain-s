//
//  WithdrawMoneySummaryNavigator.swift
//  RetailClean
//
//  Created by David Gálvez Alonso on 26/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import CoreFoundationLib
import Transfer
import UIKit

protocol WithdrawMoneySummaryNavigatorProtocol: PullOffersActionsNavigatorProtocol {
    func goToTransfers()
    func goToPG(container: OperativeContainerProtocol)
    func goToInitialView(container: OperativeContainerProtocol)
}

class WithdrawMoneySummaryNavigator: AppStoreNavigator, WithdrawMoneySummaryNavigatorProtocol {
    let presenterProvider: PresenterProvider
    let drawer: BaseMenuViewController
    
    init(presenterProvider: PresenterProvider, drawer: BaseMenuViewController) {
        self.presenterProvider = presenterProvider
        self.drawer = drawer
    }
    
    func goToTransfers() {
        launchTransferSection(.home)
    }
    
    func goToPG(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        sourceView?.navigationController?.popToRootViewController(animated: true)
    }
    
    func goToInitialView(container: OperativeContainerProtocol) {
        let sourceView = container.operativeContainerNavigator.sourceView
        if let sourceView = sourceView, let index = sourceView.navigationController?.viewControllers.firstIndex(of: sourceView), index > 1, let destination = sourceView.navigationController?.viewControllers[index - 1] {
            sourceView.navigationController?.popToViewController(destination, animated: true)
        } else {
            sourceView?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension WithdrawMoneySummaryNavigator: TransferModuleCoordinatorLauncher {
    var navigationController: UINavigationController {
        return drawer.currentRootViewController as? UINavigationController ?? UINavigationController()
    }
    
    var navigatorProvider: NavigatorProvider {
        return presenterProvider.navigatorProvider
    }

    var transferDependenciesEngine: DependenciesResolver & DependenciesInjector {
        return presenterProvider.dependenciesEngine
    }

    var transferExternalResolver: TransferExternalDependenciesResolver {
        return presenterProvider.navigatorProvider.legacyExternalDependenciesResolver
    }
}
