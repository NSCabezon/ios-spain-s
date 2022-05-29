//
//  RetailLegacyPrivateMenuExternalDependenciesResolver.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 1/2/22.
//

import UI
import CoreFoundationLib

public protocol RetailLegacyPrivateMenuExternalDependenciesResolver: 
    CoreDependencies,
    PrivateMenuEventsRepositoryDependenciesResolver {
    func resolve() -> DependenciesResolver
    func helpCenterCoordinator() -> BindableCoordinator
    func branchLocatorCoordinator() -> BindableCoordinator
    func securityCoordinator() -> BindableCoordinator
    func myManagerCoordinator() -> BindableCoordinator
    func privateMenuCoordinator() -> BindableCoordinator
    func personalAreaCoordinator() -> BindableCoordinator
    func sendMoneyHomeCoordinator() -> BindableCoordinator
    func financingHomeCoordinator() -> BindableCoordinator
    func billAndTaxesHomeCoordinator() -> BindableCoordinator
    func analysisAreaHomeCoordinator() -> BindableCoordinator
    func topUpsCoordinator() -> BindableCoordinator
    func privateMenuContractViewCoordinator() -> BindableCoordinator
    func privateMenuWebConfigurationCoordinator() -> BindableCoordinator
    func privateSubMenuActionCoordinator() -> BindableCoordinator
    func privateSubMenuVariableIncome() -> BindableCoordinator
    func privateSubMenuStockholders() -> BindableCoordinator
    func privateMenuComingSoon() -> BindableCoordinator
    func privateMenuOpinatorCoordinator() -> BindableCoordinator
}

public extension RetailLegacyPrivateMenuExternalDependenciesResolver {
    func helpCenterCoordinator() -> BindableCoordinator {
        return HelpCenterCoordinator(dependencies: self)
    }
    
    func branchLocatorCoordinator() -> BindableCoordinator {
        return BranchLocatorCoordinator(dependencies: self)
    }
    
    func securityCoordinator() -> BindableCoordinator {
        return SecurityCoordinator(dependencies: self)
    }
    
    func myManagerCoordinator() -> BindableCoordinator {
        return PersonalManagerCoordinator(dependencies: self)
    }
    
    func personalAreaCoordinator() -> BindableCoordinator {
        return PrivateMenuPersonalAreaCoordinator(dependencies: self)
    }
    
    func sendMoneyHomeCoordinator() -> BindableCoordinator {
        return SendMoneyCoordinator(dependencies: self)
    }
    
    func financingHomeCoordinator() -> BindableCoordinator {
        return FinanceCoordinator(dependencies: self)
    }
    
    func billAndTaxesHomeCoordinator() -> BindableCoordinator {
        return BillAndTaxesCoordinator(dependencies: self)
    }
    
    func topUpsCoordinator() -> BindableCoordinator {
        return TopUpCoordinator(dependencies: self)
    }
    
    func privateMenuContractViewCoordinator() -> BindableCoordinator {
        return ContractViewCoordinator(dependencies: self)
    }
    
    func privateMenuWebConfigurationCoordinator() -> BindableCoordinator {
        return WebViewCoordinator(dependencies: self)
    }
    
    func logoutCoordinator() -> BindableCoordinator {
        return LogOutCoordinator(dependencies: self)
    }
    
    func privateSubMenuActionCoordinator() -> BindableCoordinator {
        return PrivateSubMenuActionCoordinator(dependencies: self)
    }
    
    func privateSubMenuVariableIncome() -> BindableCoordinator {
        return PrivateSubMenuVariableIncomeCoordinator(dependencies: self)
    }
    
    func privateSubMenuStockholders() -> BindableCoordinator {
        return PrivateSubMenuStockholdersCoordinator(dependencies: self)
    }
    
    func privateMenuComingSoon() -> BindableCoordinator {
        return PrivateMenuComingSoonCoordinator(dependencies: self)
    }
    
    func privateMenuOpinatorCoordinator() -> BindableCoordinator {
        return OpinatorCoordinator(dependencies: self)
    }
}
