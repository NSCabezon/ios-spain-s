//
//  TestInternalTransferSummaryDependenciesResolver.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Mario Rosales Maillo on 28/3/22.
//

import Foundation
@testable import TransferOperatives
import CoreFoundationLib

struct TestInternalTransferSummaryDependenciesResolver: InternalTransferSummaryDependenciesResolver {
    private let dataBinding = DataBindingObject()
    var external: InternalTransferSummaryExternalDependenciesResolver
    
    init(externalDependencies: InternalTransferSummaryExternalDependenciesResolver) {
        external = externalDependencies
    }
    
    func resolve() -> DataBinding {
        return dataBinding
    }
    
    func resolve() -> InternalTransferOperative {
        fatalError()
    }
    
    func resolve() -> InternalTransferSummaryViewModel {
        fatalError()
    }
    
    func resolve() -> InternalTransferSummaryViewController {
        fatalError()
    }
    
    func resolve() -> InternalTransferOperativeCoordinator {
        fatalError()
    }
}
