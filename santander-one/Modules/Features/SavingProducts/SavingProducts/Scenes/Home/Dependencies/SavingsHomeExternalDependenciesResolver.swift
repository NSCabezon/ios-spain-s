//
//  SavingsHomeExternalDependenciesResolver.swift
//  Account
//
//  Created by Adrian Escriche Martin on 14/2/22.
//
import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import OpenCombine

public protocol SavingsHomeExternalDependenciesResolver: ShareDependenciesResolver, NavigationBarExternalDependenciesResolver, SavingsOtherOperativesExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> GetSavingProductOptionsUseCase
    func resolve() -> GetSavingProductComplementaryDataUseCase
    func resolve() -> GlobalPositionDataRepository
    func resolve() -> SavingTransactionsRepository
    func resolve() -> TimeManager
    func resolve() -> StringLoader
    func resolve() -> SharedHandler
    func resolveSavingsShowPDFCoordinator() -> BindableCoordinator
    func savingsHomeCoordinator() -> BindableCoordinator
    func savingDetailCoordinator() -> BindableCoordinator
    func savingsCustomOptionCoordinator() -> BindableCoordinator
    func defaultSavingsHomeCoordinator() -> SavingsHomeCoordinator
    func resolve() -> SavingsHomeTransactionsActionsUseCase
    func resolve() -> GetSavingProductsUsecase
    func savingsHomeTransactionsActionsCoordinator() -> BindableCoordinator
    func resolve() -> TrackerManager
    func otherOperativesCoordinator() -> BindableCoordinator
    func resolve() -> AccountNumberFormatterProtocol?
    func resolve() -> SavingsCheckNewHomeSendMoneyIsEnabledUseCase
    func savingsOneTransferHomeCoordinator() -> BindableCoordinator
    func savingsSendMoneyCoordinator() -> ModuleCoordinator
}

public extension SavingsHomeExternalDependenciesResolver {
    func savingsHomeCoordinator() -> BindableCoordinator {
        return defaultSavingsHomeCoordinator()
    }
    
    func defaultSavingsHomeCoordinator() -> SavingsHomeCoordinator {
        return DefaultSavingsHomeCoordinator(dependencies: self, navigationController: resolve())
    }
    
    func resolve() -> SharedHandler {
        return SharedHandler()
    }
    
    func resolve() -> GetSavingProductsUsecase {
        return DefaultGetSavingProductsUsecase(dependencies: self)
    }
    
    func resolve() -> SavingsHomeTransactionsActionsUseCase {
        return DefaultSavingsHomeTransactionsActionsUseCase()
    }

    func savingsHomeTransactionsActionsCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }

    func savingsCustomOptionCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }

    func resolve() -> GetSavingProductOptionsUseCase {
        return DefaultGetSavingProductOptionsUseCase()
    }

    func otherOperativesCoordinator() -> BindableCoordinator {
        return defaultOtherOperativesCoordinator()
    }

    func defaultOtherOperativesCoordinator() -> SavingsOtherOperativesCoordinator {
        return DefaultSavingsOtherOperativesCoordinator(dependencies: self, navigationController: resolve())
    }

    func resolve() -> AccountNumberFormatterProtocol? {
        nil
    }

    func resolve() -> SavingsCheckNewHomeSendMoneyIsEnabledUseCase {
        return DefaultSavingsCheckNewHomeSendMoneyIsEnabledUseCase()
    }

    func savingsOneTransferHomeCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }

    func savingsSendMoneyCoordinator() -> ModuleCoordinator {
        return VoidModuleCoordinator()
    }
}

private class VoidModuleCoordinator: ModuleCoordinator {
    var navigationController: UINavigationController?

    func start() {
        ToastCoordinator().start()
    }
}
