//
//  TestInternalTransferSummaryExternalDependenciesResolver.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Mario Rosales Maillo on 28/3/22.
//

import Foundation
@testable import TransferOperatives
import CoreFoundationLib
import CoreTestData

struct TestInternalTransferSummaryExternalDependenciesResolver: InternalTransferSummaryExternalDependenciesResolver {
    
    let modifier: InternalTransferSummaryModifierProtocol
    
    init(modifier: InternalTransferSummaryModifierProtocol) {
        self.modifier = modifier
    }
    
    func resolve() -> UINavigationController {
        fatalError()
    }
    
    func resolve() -> BaseURLProvider {
        return BaseURLProvider(baseURL: "http://mock")
    }
    
    func resolve() -> CurrencyFormatterProvider {
        fatalError()
    }
    
    func resolve() -> InternalTransferSummaryModifierProtocol {
        return modifier
    }
    
    func resolve() -> TrackerManager {
        return TrackerManagerMock()
    }
}
