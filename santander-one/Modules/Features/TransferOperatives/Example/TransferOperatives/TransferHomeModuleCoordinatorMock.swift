//
//  TransferHomeModuleCoordinatorMock.swift
//  TransferOperatives_Example
//
//  Created by David Gálvez Alonso on 21/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import TransferOperatives
import Operative
import CoreDomain
import Transfer

final public class TransferHomeModuleCoordinatorMock: TransferHomeModuleCoordinatorDelegate {
    public func showDialog(configuration: DialogConfiguration) {}
    public func executeOffer(_ offer: OfferRepresentable) {}
    public func modifyDeferredTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity) {}
    public func modifyPeriodicTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity) {}
    public let dependenciesResolver: DependenciesResolver
    let navigationController: UINavigationController?
    
    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.dependenciesResolver = dependenciesResolver
        self.navigationController = navigationController
    }
    
    public func showTransferDetail(_ transfer: TransferEmittedEntity, fromAccount: AccountEntity?, toAccount: AccountEntity, presentationBlock: @escaping (TransferDetailConfiguration) -> Void) {}
    
    public func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) { }
    
    public func closeNewShipmentView(_ completion: @escaping (() -> Void)) {
        completion()
    }
    
    func showTransferDetail(_ transfer: TransferEmittedEntity, fromAccount: AccountEntity?, toAccount: AccountEntity) { }

    public func didSelectMenu() {}

    public func didSelectDismiss() {}

    public func didSelectSearch() {}

    public func didSelectNewContact() {}

    public func didSelectVirtualAssistant() {}

    public func showDialog(acceptTitle: String?, cancelTitle: String?, title: String?, body: String?, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {}

    public func handleWebView(with data: Data, title: String) {}

    public func executeOffer(_ offer: OfferEntity) {}

    public func goToWebView(configuration: WebViewConfiguration) {}

    public func didSelectTransfer(_ account: AccountEntity?) {}

    func didSelectBizum() {}

    public func didSelectOnePayFX(_ offer: OfferEntity?) {}

    public func didSelectATMs() {}

    public func didSelectDonations(_ account: AccountEntity?, _ offer: OfferEntity?) {}

    public func didSelectCorreosCash(_ account: AccountEntity?, _ offer: OfferEntity?) {}

    public func didSelectTransferAction(type: TransferActionType, account: AccountEntity?) {
        self.goToSendMoney(handler: self)
    }
}

extension TransferHomeModuleCoordinatorMock: SendMoneyOperativeLauncher {}

extension TransferHomeModuleCoordinatorMock: OperativeLauncherHandler {
    
    public var operativeNavigationController: UINavigationController? {
        return self.navigationController
    }

    public func showOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }

    public func hideOperativeLoading(completion: @escaping () -> Void) {
        completion()
    }

    public func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        completion?()
    }

}
