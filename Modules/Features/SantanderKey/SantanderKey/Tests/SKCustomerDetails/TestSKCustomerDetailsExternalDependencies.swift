//
//  TestSKCustomerDetailsExternalDependencies.swift
//  SantanderKey-Unit-Tests
//
//  Created by David Gálvez Alonso on 18/4/22.
//

import CoreTestData
import CoreFoundationLib
import UI
import SANSpainLibrary

@testable import SantanderKey

struct TestSKCustomerDetailsExternalDependencies: SKCustomerDetailsExternalDependenciesResolver {
    
    let injector: MockDataInjector
    
    init(injector: MockDataInjector) {
        self.injector = injector
    }
    
    func resolve() -> SantanderKeyOnboardingRepository {
        return SantanderKeyOnboardingRepositoryMock()
    }
    
    func sKSecondStepOnboardingCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func skBiometricsStepOnboardingCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        fatalError()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> CompilationProtocol {
        return CompilationMock()
    }
    
    func resolve() -> SantanderKeyTransparentRegisterUseCase {
        fatalError()
    }
    
    func resolve() -> LocalAuthenticationPermissionsManagerProtocol {
        return LocalAuthenticationPermissionsManagerMock()
    }
    
    func resolve() -> DefaultSKOperativeCoordinator {
        fatalError()
    }
    
    func resolve() -> FaqsRepositoryProtocol {
        return MockFaqsRepository(mockDataInjector: injector)
    }
    
    func resolve() -> CoreDependencies {
        fatalError()
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        return MockAppConfigRepository(mockDataInjector: injector)
    }
}
