//
//  File.swift
//  Alamofire
//
//  Created by Juan Carlos López Robles on 10/19/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib

public final class MockDataRepositories {
    private let dependencies: DependenciesInjector & DependenciesResolver
    private let mockDataInjector: MockDataInjector
    
    public init(mockDataInjector: MockDataInjector, dependencies: DependenciesInjector & DependenciesResolver) {
        self.dependencies = dependencies
        self.mockDataInjector = mockDataInjector
    }
    
    public func registerDependencies() {
        dependencies.register(for: LoanReactiveRepository.self) { _ in
            MockLoanRepository(mockDataInjector: self.mockDataInjector)
        }
        dependencies.register(for: CardRepository.self) { _ in
            MockCardRepository(mockDataInjector: self.mockDataInjector)
        }
        dependencies.register(for: FinancialHealthRepository.self) { _ in
            MockFinancialHealthRepository(mockDataInjector: self.mockDataInjector)
        }
    }
}
