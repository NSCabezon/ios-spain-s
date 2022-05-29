//
//  AccountHomeActionTest.swift
//  Accounts_ExampleTests
//
//  Created by Juan Carlos López Robles on 2/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
@testable import Account
@testable import SANLegacyLibrary

class AccountHomeActionTest: XCTestCase {
    private let accountEntity = AccountEntity(AccountDTO())
    
    private lazy var accountHomeActionModifier: AccountHomeActionModifierMock = {
        return AccountHomeActionModifierMock()
    }()
    
    private lazy var dependenciesEngine: DependenciesDefault = {
        let dependencies = DependenciesDefault()
        dependencies.register(for: AccountActionAdapter.self) { resolver in
            return AccountActionAdapter(dependenciesResolver: resolver)
        }
        dependencies.register(for: AccountHomeActionModifierProtocol.self) { _ in
            return self.accountHomeActionModifier
        }
        dependencies.register(for: GetAccountHomeActionUseCaseProtocol.self) { resolver in
            return GetCoreAccountHomeActionUseCase(dependenciesResolver: resolver)
        }
        return dependencies
    }()
    
    func getAccountActions(accountEntity: AccountEntity) throws -> UseCaseResponse<GetAccountHomeActionUseCaseOkOutput, StringErrorOutput> {
        let input = GetAccountHomeActionUseCaseInput(
            account: accountEntity
        )
        let useCase = GetCoreAccountHomeActionUseCase(dependenciesResolver: self.dependenciesEngine)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
   
    
    func testAccountHomeActions() throws {
        let defaultAccountHomeActions: [AccountActionType] = [.transfer, .payBill, .billsAndTaxes]
        let response = try getAccountActions(accountEntity: accountEntity)
        let accountTypes = try response.getOkResult()
        let adapter = self.dependenciesEngine.resolve(for: Account.AccountActionAdapter.self)
        let viewModels = adapter.getHomeActions(accountTypes: accountTypes.actions , entity: accountEntity, action: nil)
        let generatedHomeActions: [AccountActionType] = viewModels.map { return $0.actionType }
        let areActionsEqualAndInTheSameOrder = defaultAccountHomeActions.elementsEqual(generatedHomeActions)
        
        XCTAssertTrue(areActionsEqualAndInTheSameOrder)
    }
    
    func test_select_account_action_is_handled_by_defult_for_coordinatorDelegate() throws {
        accountHomeActionModifier.didSelectAction(.billsAndTaxes, self.accountEntity)
        XCTAssertTrue(accountHomeActionModifier.actionHandleByAccountHomeCoordinatorDelegate)
    }
}

final class AccountHomeActionModifierMock: AccountHomeActionModifierProtocol {
    var actionHandleByAccountHomeCoordinatorDelegate = false
    
    func getActionButtonFillViewType(for accountType: AccountActionType) -> ActionButtonFillViewType? {
        return nil
    }
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity) {
        self.actionHandleByAccountHomeCoordinatorDelegate = true
    }
}
