//
//  InternalTransferTestDependencies.swift
//  TransferOperatives_ExampleTests
//
//  Created by Mario Rosales Maillo on 24/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import TransferOperatives
import CoreFoundationLib
import CoreTestData
import CoreDomain

struct TestInternalTransferDestinationAccountExternalDependencies: InternalTransferDestinationAccountExternalDependenciesResolver {

    var accountRepresentables: [AccountRepresentable]

    init(accounts: [AccountRepresentable]) {
        accountRepresentables = accounts
    }

    func resolve() -> UINavigationController {
        fatalError()
    }

    func resolve() -> AccountNumberFormatterProtocol? {
        return nil
    }

    func resolve() -> GlobalPositionDataRepository {
        return TestGlobalPositionDataRepository(accounts: accountRepresentables)
    }

    func resolve() -> AccountNumberFormatterProtocol {
        fatalError()
    }

    func resolve() -> TrackerManager {
        TrackerManagerMock()
    }
}
