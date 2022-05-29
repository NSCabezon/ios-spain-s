//
//  MockExternalDependencies.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 11/22/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//
import UI
import Foundation
import CoreDomain
import CoreTestData
import CoreFoundationLib
@testable import Loans

struct TestExternalDependencies: LoanHomeExternalDependenciesResolver {
    let injector: MockDataInjector
    let globalPositionRepository: MockGlobalPositionDataRepository
    
    init(injector: MockDataInjector) {
        self.injector = injector
        self.globalPositionRepository = MockGlobalPositionDataRepository(injector.mockDataProvider.gpData.getGlobalPositionMock)
    }
    
    func resolve() -> GlobalPositionDataRepository {
        return globalPositionRepository
    }
    
    func resolve() -> LoanReactiveRepository {
        MockLoanRepository(mockDataInjector: injector)
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        MockAppConfigRepository(mockDataInjector: injector)
    }
    
    func loanDetailCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func loanTransactionsSearchCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func loanTransactionDetailCoordinator() -> BindableCoordinator {
        fatalError()
    }
    
    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
   
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> TimeManager {
        fatalError()
    }
    
    func resolve() -> DependenciesResolver {
        fatalError()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        fatalError()
    }
    
    func privateMenuCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func globalSearchCoordinator() -> Coordinator {
        ToastCoordinator()
    }
    
    func loanRepaymentCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
    
    func loanChangeLinkedAccountCoordinator() -> BindableCoordinator {
        ToastCoordinator()
    }
}

final class TrackerManagerMock: TrackerManager {
    public init() {}
    public func trackScreen(screenId: String, extraParameters: [String: String]) {}
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {}
    public func trackEmma(token: String) {}
}
