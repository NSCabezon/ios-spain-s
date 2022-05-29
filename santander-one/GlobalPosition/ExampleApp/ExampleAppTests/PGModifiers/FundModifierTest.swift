//
//  FundModifierTest.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 2/4/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//

import CoreFoundationLib
import XCTest
@testable import GlobalPosition
@testable import SANLegacyLibrary

class FundModifierTest: XCTestCase {
    let dependencies = DependenciesDefault()
    let fundEntity = FundEntity(FundDTO())
    
    func test_global_position_select_fund_default_modifier() throws {
        let fundModifier = FundModifier(dependenciesResolver: dependencies)
        let defaultModifier = FundDefaultModifierMock(dependenciesResolver: dependencies)
        fundModifier.add(defaultModifier)
        fundModifier.didSelectFund(fund: self.fundEntity)
        XCTAssertTrue(defaultModifier.defaultActionExecuted)
    }
    
    func test_global_position_select_fund_modifier_reset() throws {
        let fundModifier = FundModifier(dependenciesResolver: dependencies)
        let defaultModifier = FundDefaultModifierMock(dependenciesResolver: dependencies)
        fundModifier.add(defaultModifier)
        fundModifier.reset()
        XCTAssertNil(fundModifier.next)
    }
    
    func test_global_position_select_fund_modifier_add_extra_modifiers() throws {
        let fundModifier = FundModifier(dependenciesResolver: dependencies)
        let fundDefaultModifier = FundDefaultModifierMock(dependenciesResolver: dependencies)
        let fundWebViewModifier = FundWebViewModifierMock(dependenciesResolver: dependencies)
        fundModifier.add(fundWebViewModifier)
        fundModifier
            .reset()
            .add(fundDefaultModifier)
            .add(fundWebViewModifier)
            .addExtraModifier()
        
        fundModifier.didSelectFund(fund: self.fundEntity)
        
        XCTAssertFalse(fundDefaultModifier.defaultActionExecuted)
        XCTAssertTrue(fundWebViewModifier.didGotoWebView)
    }
}

final class FundDefaultModifierMock: FundModifier {
    var defaultActionExecuted = false
    
    override func didSelectFund(fund: FundEntity) {
        if self.next == nil {
            self.defaultActionExecuted = true
        } else {
            super.didSelectFund(fund: fund)
        }
    }
    
    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
}

final class FundWebViewModifierMock: FundModifier {
    var didGotoWebView = false
    
    override func didSelectFund(fund: FundEntity) {
        if self.next == nil {
            self.didGotoWebView = true
        } else {
            super.didSelectFund(fund: fund)
        }
    }
}
