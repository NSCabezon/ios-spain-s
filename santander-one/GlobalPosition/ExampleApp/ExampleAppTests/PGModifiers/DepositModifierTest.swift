//
//  PFModifiers.swift
//  ExampleAppTests
//
//  Created by Juan Carlos López Robles on 2/3/21.
//  Copyright © 2021 Jose Carlos Estela Anguita. All rights reserved.
//
import CoreFoundationLib
import XCTest
@testable import GlobalPosition
@testable import SANLegacyLibrary

class DepositModifierTest: XCTestCase {

    let dependencies = DependenciesDefault()
    let depositEntity = DepositEntity(DepositDTO())
    
    func test_global_position_select_deposit_default_modifier() throws {
        let depositModifier = DepositModifier(dependenciesResolver: dependencies)
        let defaultModifier = DepositDefaultModifierMock(dependenciesResolver: dependencies)
        depositModifier.add(defaultModifier)
        depositModifier.didSelectDeposit(deposit: self.depositEntity)
        XCTAssertTrue(defaultModifier.defaultActionExecuted)
    }
    
    func test_global_position_select_deposit_modifier_reset() throws {
        let depositModifier = DepositModifier(dependenciesResolver: dependencies)
        let defaultModifier = DepositDefaultModifierMock(dependenciesResolver: dependencies)
        depositModifier.add(defaultModifier)
        depositModifier.reset()
        XCTAssertNil(depositModifier.next)
    }
    
    func test_global_position_select_deposit_modifier_add_extra_modifiers() throws {
        let depositModifier = DepositModifier(dependenciesResolver: dependencies)
        let depositDefaultModifier = DepositDefaultModifierMock(dependenciesResolver: dependencies)
        let depositWebViewModifier = DepositWebViewModifierMock(dependenciesResolver: dependencies)
        depositModifier
            .reset()
            .add(depositDefaultModifier)
            .add(depositWebViewModifier)
            .addExtraModifier()
        
        depositModifier.didSelectDeposit(deposit: self.depositEntity)
        
        XCTAssertFalse(depositDefaultModifier.defaultActionExecuted)
        XCTAssertTrue(depositWebViewModifier.didGotoWebView)
    }
}

final class DepositDefaultModifierMock: DepositModifier {
    var defaultActionExecuted = false
    
    override func didSelectDeposit(deposit: DepositEntity) {
        if self.next == nil {
            self.defaultActionExecuted = true
        } else {
            super.didSelectDeposit(deposit: deposit)
        }
    }
    
    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
}

final class DepositWebViewModifierMock: DepositModifier {
    var didGotoWebView = false
    
    override func didSelectDeposit(deposit: DepositEntity) {
        if self.next == nil {
            self.didGotoWebView = true
        } else {
            super.didSelectDeposit(deposit: deposit)
        }
    }
}
