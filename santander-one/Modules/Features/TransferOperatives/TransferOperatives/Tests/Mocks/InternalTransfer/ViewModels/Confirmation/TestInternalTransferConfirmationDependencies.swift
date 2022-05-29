//
//  TestInternalTransferConfirmationDependencies.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Juan Sánchez Marín on 16/3/22.
//

@testable import TransferOperatives
import CoreFoundationLib

struct TestInternalTransferConfirmationDependencies: InternalTransferConfirmationDependenciesResolver {
    private let dataBinding = DataBindingObject()
    private let operativeCoordinator: InternalTransferOperativeCoordinator
    var external: InternalTransferConfirmationExternalDependenciesResolver

    init(externalDependencies: TestInternalTransferConfirmationExternalDependencies, operativeCoordinator: InternalTransferOperativeCoordinator) {
        self.external = externalDependencies
        self.operativeCoordinator = operativeCoordinator
    }

    func resolve() -> DataBinding {
        return dataBinding
    }

    func resolve() -> InternalTransferOperative {
        fatalError()
    }

    func resolve() -> InternalTransferConfirmationViewModel {
        fatalError()
    }

    func resolve() -> InternalTransferConfirmationViewController {
        fatalError()
    }

    func resolve() -> InternalTransferOperativeCoordinator {
        return operativeCoordinator
    }
}
