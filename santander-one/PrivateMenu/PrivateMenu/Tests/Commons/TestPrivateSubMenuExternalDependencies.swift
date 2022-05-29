//
//  TestPrivateSubMenuExternalDependenciesResolver.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain
import CoreFoundationLib
import CoreTestData
@testable import PrivateMenu
import UI

struct TestPrivateSubMenuExternalDependencies {
    let injector: MockDataInjector
    let getPersonalManagerUseCaseSpy = GetPersonalManagerUseCaseSpy()
    let getCandidateOfferUseCaseSpy = GetCandidateOfferUseCaseSpy()
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
}

extension TestPrivateSubMenuExternalDependencies: PrivateSubMenuExternalDependenciesResolver {
    func fundsHomeCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> ReactivePullOffersInterpreter {
        MockReactivePullOffersInterpreter(mockDataInjector: injector)
    }
    
    func resolve() -> GetCandidateOfferUseCase {
        self.getCandidateOfferUseCaseSpy
    }
    
    func resolve() -> PrivateMenuToggleOutsider {
        MocKPrivateMenuTogglerOutsider()
    }
    
    func resolve() -> GetPersonalManagerUseCase {
        self.getPersonalManagerUseCaseSpy
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolveSideMenuNavigationController() -> UINavigationController {
        fatalError()
    }
    
    func securityCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func branchLocatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func helpCenterCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func myManagerCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolveOfferCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateSubMenuActionCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateSubMenuVariableIncome() -> BindableCoordinator {
        fatalError()
    }
    
    func privateSubMenuStockholders() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuComingSoon() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuOpinatorCoordinator() -> BindableCoordinator {
        fatalError()
    }
}
