//
//  GlobalSearchHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by alvola on 21/02/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import GlobalSearch
import UI
import CoreFoundationLib
import Operative
import Cards
import CoreDomain

final class GlobalSearchHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    
}

extension GlobalSearchHomeCoordinatorNavigator: GlobalSearchMainModuleCoordinatorDelegate {
    
    func didSelectDismiss() { viewController?.navigationController?.popViewController(animated: true) }
    
    func didSelectAccountMovement(_ movement: AccountTransactionEntity, in transactions: [AccountTransactionWithAccountEntity], for account: AccountEntity) {
        navigatorProvider.privateHomeNavigator.showAccountTransaction(movement, in: transactions, for: account, associated: false)
    }
    
    func didSelectCardMovement(_ movement: CardTransactionEntity, in transactions: [CardTransactionWithCardEntity], for card: CardEntity) {
        navigatorProvider.privateHomeNavigator.showCardTransaction(movement, in: transactions, for: card)
    }
    
    private func didSelectMovement(_ product: GenericProduct & GenericProductProtocol, _ transactions: [GenericTransactionProtocol], _ productHome: PrivateMenuProductHome) {
        navigatorProvider.productHomeNavigator.goToTransactionDetail(product: product,
                                                                     transactions: transactions,
                                                                     selectedPosition: 0,
                                                                     productHome: productHome,
                                                                     syncDelegate: nil,
                                                                     optionsDelegate: nil)
    }
    
    func goToBills() {
        navigatorProvider.privateHomeNavigator.goToBillsAndTaxes()
    }
    
    func goToTransfers() {
        navigatorProvider.privateHomeNavigator.goToTransfers(section: .home)
    }
    
    func goToSwitchOffCard() {
        goToCardOnOff(card: nil, option: .turnOff, handler: self)
    }
    
    func open(url: String) {
        navigatorProvider.privateHomeNavigator.open(url: url)
    }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText? = nil, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        guard let viewController = viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: title, body: body, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: viewController)
    }
}

extension GlobalSearchHomeCoordinatorNavigator: CardOnOffOperativeLauncher {
    
    var cardExternalDependencies: CardExternalDependenciesResolver {
        return navigatorProvider.cardExternalDependenciesResolver
    }
    
    var operativePresentationDelegate: OperativeLauncherPresentationDelegate? {
        return self
    }
    
    var origin: OperativeLaunchedFrom {
        return .home
    }
    
    var navigatorLauncher: OperativesNavigatorProtocol {
        return navigator
    }
}
