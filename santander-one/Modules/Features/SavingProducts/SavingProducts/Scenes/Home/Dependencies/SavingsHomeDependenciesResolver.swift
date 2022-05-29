//
//  SavingsHomeDependenciesResolver.swift
//  Pods
//
//  Created by Adrian Escriche Martin on 15/2/22.
//
import UI
import CoreFoundationLib
import Foundation

protocol SavingsHomeDependenciesResolver {
    var external: SavingsHomeExternalDependenciesResolver { get }
    func resolve() -> SavingsHomeViewModel
    func resolve() -> SavingsHomeViewController
    func resolve() -> SavingsHomeCoordinator
    func resolve() -> DataBinding
    func resolve() -> GetSavingTransactionsUseCase
}

extension SavingsHomeDependenciesResolver {
    func resolve() -> SavingsHomeViewModel {
        return SavingsHomeViewModel(dependencies: self)
    }
    func resolve() -> SavingsHomeViewController {
        return SavingsHomeViewController(dependencies: self)
    }
    func resolve() -> GetSavingTransactionsUseCase {
        return DefaultGetSavingTransactionsUseCase(repository: external.resolve())
    }
}
