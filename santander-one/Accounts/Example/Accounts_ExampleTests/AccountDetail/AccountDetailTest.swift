//
//  AccountDetailTest.swift
//  Accounts_ExampleTests
//
//  Created by Cristobal Ramos Laina on 11/02/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import UnitTestCommons
import SANLegacyLibrary
import CoreTestData
@testable import Account
@testable import CoreFoundationLib

class AccountDetailTest: XCTestCase {
    
    private let dependenciesResolver = DependenciesDefault()
    private var mockDataInjector = MockDataInjector()
    private var globalPosition: GlobalPositionRepresentable?
    private var selectedAccountEntity: AccountEntity?
    private var changeAccountMainUseCase: ChangeAccountMainUseCaseAlias?

    override func setUpWithError() throws {
        self.defaultRegistration()
        self.setupDependencies()
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        guard let globalPosition = self.globalPosition, globalPosition.accounts.count >= 1 else { return }
        self.selectedAccountEntity = self.globalPosition?.accounts[2]
        self.changeAccountMainUseCase = self.dependenciesResolver.resolve(for: ChangeAccountMainUseCaseAlias.self)
    }
    
    func getFundWebViewUseCase(accountEntity: AccountEntity) throws -> UseCaseResponse<GetAccountDetailUseCaseOkOutput, StringErrorOutput> {
        let input = GetAccountDetailUseCaseInput(
            account: accountEntity
        )
        let useCase = GetAccountDetailUseCase(dependenciesResolver: self.dependenciesResolver)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func getChangeAccountMainTrueUseCase(accountEntity: AccountEntity) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let input = ChangeAccountMainUseCaseInput(
            account: accountEntity,
            main: true
        )
        guard let useCase = self.changeAccountMainUseCase else { return UseCaseResponse.error(StringErrorOutput("")) }
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func getChangeAccountMainFalseUseCase(accountEntity: AccountEntity) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let input = ChangeAccountMainUseCaseInput(
            account: accountEntity,
            main: false
        )
        guard let useCase = self.changeAccountMainUseCase else { return UseCaseResponse.error(StringErrorOutput("")) }
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func test_GetAccountDetailUseCase_Exist_Retention() throws {
        do {
            guard let accountEntity = self.globalPosition?.accounts[1] else { return }
            self.mockDataInjector.register(for: \.accountData.getAccountDetailMock, filename: "detalleCuenta")
            let response = try getFundWebViewUseCase(accountEntity: accountEntity)
            guard response.isOkResult else {
                XCTFail("GetAccountDetailUseCase fail")
                return
            }
            let categoryResponse = try response.getOkResult()
            let viewModel = AccountDetailDataViewModel(accountEntity: accountEntity, accountDetailEntity: categoryResponse.detail, holder: "", dependenciesResolver: self.dependenciesResolver)
            let view = AccountDetailDataView()
            view.setupAccountDetailDataView(viewModel: viewModel)
            XCTAssertFalse(view.amountRetentionLabelIsHidden)
        } catch {
            XCTFail("GetAccountDetailUseCase: throw")
        }
    }
    
    func test_GetAccountDetailUseCase_Not_Exist_Retention() throws {
        do {
            self.mockDataInjector.register(for: \.accountData.getAccountDetailMock, filename: "detalleCuenta_Not_Exist_Retention")
            guard let accountEntity = self.globalPosition?.accounts[0] else { return }
            let response = try getFundWebViewUseCase(accountEntity: accountEntity)
            guard response.isOkResult else {
                XCTFail("GetAccountDetailUseCase fail")
                return
            }
            let categoryResponse = try response.getOkResult()
            let viewModel = AccountDetailDataViewModel(accountEntity: accountEntity, accountDetailEntity: categoryResponse.detail, holder: "", dependenciesResolver: self.dependenciesResolver)
            let view = AccountDetailDataView()
            view.setupAccountDetailDataView(viewModel: viewModel)
            XCTAssertTrue(view.amountRetentionLabelIsHidden)
        } catch {
            XCTFail("GetAccountDetailUseCase: throw")
        }
    }
    
    func test_ChangeAccountMainUseCase_main_true() throws {
        do {
            guard let accountEntity = self.globalPosition?.accounts[1] else { return }
            let response = try getChangeAccountMainTrueUseCase(accountEntity: accountEntity)
            guard response.isOkResult else {
                XCTFail("GetAccountDetailUseCase: main can`t be false")
                return
            }
        } catch {
            XCTFail("GetAccountDetailUseCase: throw")
        }
    }
    
    func test_ChangeAccountMainUseCase_main_false() throws {
        do {
            guard let accountEntity = self.globalPosition?.accounts[1] else { return }
            let response = try getChangeAccountMainFalseUseCase(accountEntity: accountEntity)
            guard response.isOkResult else {
                return
            }
            XCTFail("ChangeAccountMainUseCase fail")
        } catch {
            XCTFail("ChangeAccountMainUseCase: throw")
        }
    }
}

private extension AccountDetailTest {
    func setupDependencies() {
        self.dependenciesResolver.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        
        self.dependenciesResolver.register(for: GlobalPositionRepresentable.self) { _ in
            return GlobalPositionMock(
                self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
                cardsData: [:],
                temporallyOffCards: [:],
                inactiveCards: [:],
                cardBalances: [:]
            )
        }
        
        self.dependenciesResolver.register(for: AppRepositoryProtocol.self) { _ in
            return AppRepositoryMock()
        }
        
        self.dependenciesResolver.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            let merger = GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
            return merger
        }
        
        dependenciesResolver.register(for: ChangeAccountMainUseCaseAlias.self) { resolver in
            return ChangeAccountMainUseCase(dependenciesResolver: resolver)
        }
    }
    
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal"
        )
    }
}
