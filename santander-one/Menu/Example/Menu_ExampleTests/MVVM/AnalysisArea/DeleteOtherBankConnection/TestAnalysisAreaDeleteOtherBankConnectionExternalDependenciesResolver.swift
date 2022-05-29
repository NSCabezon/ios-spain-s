//
//  TestAnalysisAreaDeleteOtherBankConnectionExternalDependenciesResolver.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 24/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UI
import CoreFoundationLib
import Foundation
import CoreDomain
import QuickSetup
import CoreTestData
@testable import Menu

extension TestExternalDependencies: DeleteOtherBankConnectionExternalDependenciesResolver {
    func resolve() -> FinancialHealthRepository {
        MockFinancialHealthRepository(mockDataInjector: self.injector)
    }
}
