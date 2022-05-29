//
//  InternalTransferTestDependencies.swift
//  TransferOperatives_ExampleTests
//
//  Created by Mario Rosales Maillo on 24/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

@testable import TransferOperatives
import CoreFoundationLib
import CoreTestData
import CoreDomain

struct TestInternalTransferAmountDependencies: InternalTransferAmountDependenciesResolver {
    private let dataBinding = DataBindingObject()
    var external: InternalTransferAmountExternalDependenciesResolver

    init(externalDependencies: TestInternalTransferAmountExternalDependencies) {
        external = externalDependencies
    }

    func resolve() -> DataBinding {
        return dataBinding
    }

    func resolve() -> InternalTransferOperative {
        fatalError()
    }

    func resolve() -> InternalTransferAmountViewModel {
        fatalError()
    }

    func resolve() -> InternalTransferAmountViewController {
        fatalError()
    }

    func resolve() -> InternalTransferOperativeCoordinator {
        let operativeDependencies = TestInternalTransferOperativeDependencies()
        return InternalTransferOperativeCoordinatorMock(dependencies: operativeDependencies)
    }
}

struct TestInternalTransferAmountExternalDependencies: InternalTransferAmountExternalDependenciesResolver {
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
    
    func resolve() -> CurrencyFormatterProvider {
        return MockCurrencyFormatterProvider()
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }

    func resolve() -> DependenciesResolver {
        fatalError()
    }

    func resolve() -> InternalTransferAmountModifierProtocol? {
        return nil
    }
}
