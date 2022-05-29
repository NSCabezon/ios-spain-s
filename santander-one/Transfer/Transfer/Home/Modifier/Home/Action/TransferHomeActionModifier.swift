//
//  TransferHomeActionModifier.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 25/02/2021.
//

import CoreFoundationLib
import CoreDomain
import Foundation

public protocol TransferHomeModifierSearchDelegate: AnyObject {
    func didSelectSearch(_ searchEnabled: @escaping (Bool) -> Void)
}

public protocol TransferHomeModifierActionsDataSource: AnyObject {
    func getNewShipmentTransferActions(_ isTransferBetweenAccountsAvailable: Bool) -> [TransferActionType]
    func getHomeTransferActions(_ transferBetweenAccountsAvailable: Bool) -> [TransferActionType]
}

public protocol TransferHomeModifierActionsDelegate: AnyObject {
    func didSelectTransferAction(type: TransferActionType, account: AccountEntity?)
    func canHandleAction(_ action: TransferActionType) -> Bool
}

public protocol TransferHomeModifierContactDelegate: AnyObject {
    func didSelectNewContact()
    func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate)
}

public struct TransferHomeModifier {
    public let dependenciesResolver: DependenciesResolver
    
    private var coordinator: TransferActionCoordinator {
        return self.dependenciesResolver.resolve(for: TransferActionCoordinator.self)
    }
    private var coordinatorDelegate: TransferHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinatorDelegate.self)
    }
    private weak var actionsDataSource: TransferHomeModifierActionsDataSource? {
        return dependenciesResolver.resolve(forOptionalType: TransferHomeModifierActionsDataSource.self)
    }
    private weak var actionsDelegate: TransferHomeModifierActionsDelegate? {
        return dependenciesResolver.resolve(forOptionalType: TransferHomeModifierActionsDelegate.self)
    }
    private weak var searchDelegate: TransferHomeModifierSearchDelegate? {
        return dependenciesResolver.resolve(forOptionalType: TransferHomeModifierSearchDelegate.self)
    }
    private weak var contactDelegate: TransferHomeModifierContactDelegate? {
        return dependenciesResolver.resolve(forOptionalType: TransferHomeModifierContactDelegate.self)
    }
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func getNewShipmentTransferActions(_ transferBetweenAccountsAvailable: Bool) -> [TransferActionType] {
        return self.actionsDataSource?.getNewShipmentTransferActions(transferBetweenAccountsAvailable) ?? [.transfer, .transferBetweenAccounts, .onePayFX(nil), .atm, .correosCash(nil), .scheduleTransfers, .donations(nil)]
    }
    
    func getHomeTransferActions(_ transferBetweenAccountsAvailable: Bool) -> [TransferActionType] {
        return self.actionsDataSource?.getHomeTransferActions(transferBetweenAccountsAvailable) ?? [.transfer, .transferBetweenAccounts, .onePayFX(nil), .atm]
    }
    
    func didSelectTransferAction(type: TransferActionType, account: AccountEntity?) {
        guard let delegate = self.actionsDelegate,
              delegate.canHandleAction(type)
        else {
            return self.didSelectTransferActionCoordinator(type: type, account: account)
        }
        return delegate.didSelectTransferAction(type: type, account: account)
    }
    
    func didSelectNewContact() {
        self.performModifiedActionOrDefault(
            modifiedAction: {
                self.contactDelegate?.didSelectNewContact()
            },
            defaultAction: {
                self.coordinatorDelegate.didSelectNewContact()
            }
        )
    }
    
    func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        self.performModifiedActionOrDefault(
            modifiedAction: {
                self.contactDelegate?.didSelectContact(contact: contact, launcher: launcher, delegate: delegate)
            },
            defaultAction: {
                self.dependenciesResolver.resolve(for: TransferHomeModuleCoordinator.self).didSelectContact(contact: contact, launcher: launcher, delegate: delegate)
            }
        )
    }
    
    func didSelectSearch() {
        self.performModifiedActionOrDefault(
            modifiedAction: {
                self.searchDelegate?.didSelectSearch({ enabled in
                    guard enabled else { return}
                    self.coordinatorDelegate.didSelectSearch()
                })
            },
            defaultAction: {
                self.coordinatorDelegate.didSelectSearch()
            }
        )
    }
}

private extension TransferHomeModifier {
    func performModifiedActionOrDefault(modifiedAction: () -> Void?, defaultAction: () -> Void) {
        modifiedAction() ?? defaultAction()
    }
    
    func didSelectTransferActionCoordinator(type: TransferActionType, account: AccountEntity?) {
        switch type {
        case .scheduleTransfers:
            self.coordinator.didSelectScheduledTransfers()
        default:
            self.coordinatorDelegate.didSelectTransferAction(type: type, account: account)
        }
    }
}
