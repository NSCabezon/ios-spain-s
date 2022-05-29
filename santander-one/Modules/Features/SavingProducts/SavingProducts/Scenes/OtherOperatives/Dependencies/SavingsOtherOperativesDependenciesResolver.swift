//
//  SavingsOtherOperativesDependenciesResolver.swift
//  SavingProducts

import UI
import CoreFoundationLib
import UIOneComponents
import Foundation

protocol SavingsOtherOperativesDependenciesResolver {
   var external: SavingsOtherOperativesExternalDependenciesResolver { get }
   func resolve() -> DataBindable & OneProductMoreOptionsViewModelProtocol
   func resolve() -> OneProductMoreOptionsViewController
   func resolve() -> SavingsOtherOperativesCoordinator
   func resolve() -> DataBinding
}

extension SavingsOtherOperativesDependenciesResolver {
   func resolve() -> DataBindable & OneProductMoreOptionsViewModelProtocol {
       return SavingsOtherOperativesViewModel(dependencies: self)
   }

   func resolve() -> OneProductMoreOptionsViewController {
       return OneProductMoreOptionsViewController(viewModel: resolve())
   }
}
