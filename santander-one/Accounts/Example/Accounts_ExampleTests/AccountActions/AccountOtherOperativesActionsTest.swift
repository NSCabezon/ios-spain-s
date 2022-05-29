//
//  AccountOtherOperativesActionsTest.swift
//  Accounts_ExampleTests
//
//  Created by Juan Carlos López Robles on 2/8/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import QuickSetup
@testable import Account
@testable import SANLegacyLibrary

class AccountOtherOperativesActionsTest: XCTestCase {
    private let accountEntity = AccountEntity(AccountDTO())
    private var accounts = [AccountEntity(AccountDTO()), AccountEntity(AccountDTO())]
  
    private lazy var dependenciesEngine: DependenciesDefault = {
        let dependencies = DependenciesDefault()
        dependencies.register(for: AccountActionAdapter.self) { resolver in
            return AccountActionAdapter(dependenciesResolver: resolver)
        }
        return dependencies
    }()
    
    func getAccountActions(account: AccountEntity) throws -> UseCaseResponse<GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
        let input = GetAccountOtherOperativesActionUseCaseInput(
            account: accountEntity
        )
        let useCase = GetCoreAccountOtherOperativesActionUseCase(dependenciesResolver: self.dependenciesEngine)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func getAccountsActions(account: AccountEntity) throws -> UseCaseResponse<GetAccountOtherOperativesActionUseCaseOkOutput, StringErrorOutput> {
        let input = GetAccountOtherOperativesActionUseCaseInput(
            account: accountEntity
        )
        let useCase = GetCoreAccountOtherOperativesActionUseCase(dependenciesResolver: self.dependenciesEngine)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }


    func test_add_account_default_other_operatives_actions_without_offer_actions() throws {
     let defaultEveryDayOperatives: [AccountActionType] = [
            .internalTransfer, .favoriteTransfer,
            .payTax, .returnBill, .changeDomicileReceipt,
            .cancelBill
        ]
        let response = try getAccountsActions(account: accountEntity)
        let accountTypes = try response.getOkResult()
        let adapter = self.dependenciesEngine.resolve(for: Account.AccountActionAdapter.self)
        let offers: [PullOfferLocation: OfferEntity] = [:]
        let viewModels = adapter.getOtherOperativeActions(entity: self.accountEntity, offers: offers, action: nil, accounts: accounts, otherOperativesActions: accountTypes.everyDayOperatives)
        let generatedHomeActions: [AccountActionType] = viewModels.map { return $0.actionType }
        let areActionsEqualAndInTheSameOrder = defaultEveryDayOperatives.elementsEqual(generatedHomeActions)
        
        XCTAssertTrue(areActionsEqualAndInTheSameOrder)

    }
}
