//
//  CardExternalDependenciesResolver.swift
//  Santander
//
//  Created by Gloria Cano López on 4/3/22.
//

import UI
import Cards
import CoreFoundationLib
import CoreDomain
import Foundation
import RetailLegacy

extension ModuleDependencies: CardExternalDependenciesResolver {
    func showPANCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func activeCardCoordinator() -> BindableCoordinator {
        return ToastCoordinator()
    }
    
    func resolve() -> CardRepository {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
  
    func resolve() -> [CardTextColorEntity] {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> GetCardDetailConfigurationUseCase {
        return SpainGetCardDetailConfigurationUseCase()
    }
    
    func resolve() -> GetCardsExpensesCalculationUseCase {
        let oldResolver: DependenciesResolver = resolve()
        return oldResolver.resolve()
    }
    
    func resolve() -> CardTransactionFilterValidator {
        return SpainCardTransactionFilterValidator(dependencies: self)
    }
    
    func resolve() -> CardTransactionAvailableFiltersUseCase {
        return SpainCardTransactionAvailableFiltersUseCase()
    }
}

extension ModuleDependencies: SpainCardTransactionFilterValidatorDependenciesResolver {
    func resolve() -> OldDialogViewPresentationCapable {
        return DefaultOldDialogView(dependencies: self)
    }
    
    func resolve() -> FirstFeeInfoEasyPayReactiveUseCase {
        return DefaultFirstFeeInfoEasyPayReactiveUseCase(repository: resolve())
    }
    
    func cardExternalDependenciesResolver() -> CardExternalDependenciesResolver {
        return self
    }
}
