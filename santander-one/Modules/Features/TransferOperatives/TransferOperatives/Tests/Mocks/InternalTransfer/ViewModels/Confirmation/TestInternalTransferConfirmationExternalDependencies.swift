//
//  TestInternalTransferConfirmationExternalDependencies.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Juan Sánchez Marín on 16/3/22.
//

@testable import TransferOperatives
import CoreFoundationLib
import CoreDomain

struct TestInternalTransferConfirmationExternalDependencies: InternalTransferConfirmationExternalDependenciesResolver {
    var trackerManager: TrackerManager

    init(trackerManager: TrackerManager) {
        self.trackerManager = trackerManager
    }

    func resolve() -> UINavigationController {
        fatalError()
    }

    func resolve() -> TransfersRepository {
        fatalError()
    }

    func resolve() -> InternalTransferConfirmationUseCase {
        fatalError()
    }

    func resolve() -> TrackerManager {
        return trackerManager
    }
    
    func resolve() -> BaseURLProvider {
        return BaseURLProvider(baseURL: "")
    }
    
    func resolve() -> CurrencyFormatterProvider {
        fatalError()
    }
    
    func resolve() -> InternalTransferConfirmationModifierProtocol {
        return MockInternalTransferConfirmationModifier()
    }
}
