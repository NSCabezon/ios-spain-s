//
//  InternalTransferAccountSelectorViewModelTest.swift
//  TransferOperatives_ExampleTests
//
//  Created by Mario Rosales Maillo on 23/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import OpenCombine
import CoreFoundationLib
import CoreTestData
import CoreDomain
import UnitTestCommons
import Operative
import UI

@testable import TransferOperatives

class InternalTransferAccountSelectorViewModelTest: XCTestCase {
    private var mockDataInjector = MockDataInjector()
    private var trackerManager: TrackerManagerMock!
    private var globalPositionMock: GlobalPositionRepresentable!
    
    private var operativeDependencies: TestInternalTransferOperativeDependencies!
    
    private var dependencies: TestInternalTransferAccountSelectorDependencies!
    private var operativeCoordinator: InternalTransferOperativeCoordinatorMock!
    private var sut: InternalTransferAccountSelectorViewModel!
    
    override func setUp() {
        defaultRegistration()
        globalPositionMock = getGlobalPositionMock()
        trackerManager = TrackerManagerMock()
        operativeDependencies = TestInternalTransferOperativeDependencies()
        operativeCoordinator = InternalTransferOperativeCoordinatorMock(dependencies: operativeDependencies)
        dependencies = TestInternalTransferAccountSelectorDependencies(
            externalDependencies: TestInternalTransferAccountSelectorExternalDependencies(accounts: filterAccounts(), trackerManager: trackerManager),
            operativeCoordinator: operativeCoordinator
        )
        operativeDependencies.coordinator = operativeCoordinator
        sut = InternalTransferAccountSelectorViewModel(dependencies: dependencies)
    }
    
    override func tearDownWithError() throws {
        dependencies = nil
    }
    
    func test_GivenSceneLaunchesAndAccountsAreLoaded_WhenVisibleAccountsAreProvided_Then_VisibleAccountsShouldBeSentToTheView() throws {
        setInDataBinding { operativeData in
            let accounts = globalPositionMock.accounts.map { $0.representable }
            operativeData.originAccountsVisibles = accounts
        }
        
        let publisher = sut.state
            .case { InternalTransferAccountSelectorState.loaded }
        sut.viewDidLoad()
        
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result.visible.isEmpty)
        XCTAssert(result.notVisible.isEmpty)
    }
    
    func test_GivenSceneLaunchesAndAccountsAreLoaded_WhenVisibleAndNotVisibleAccountsAreProvided_Then_VisibleAndNotVisibleAccountsShouldBeSentToTheView() throws {
        setInDataBinding { operativeData in
            let accounts = globalPositionMock.accounts.map { $0.representable }
            operativeData.originAccountsVisibles = accounts
            operativeData.originAccountsNotVisibles = accounts
        }
        
        let publisher = sut.state
            .case { InternalTransferAccountSelectorState.loaded }
        sut.viewDidLoad()
        
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result.visible.isEmpty)
        XCTAssertFalse(result.notVisible.isEmpty)
    }
    
    func test_GivenSceneLaunchesAndAccountsAreLoaded_WhenNotVisibleAccountsAreProvided_Then_NotVisibleAccountsShouldBeSentToTheView() throws {
        setInDataBinding { operativeData in
            let accounts = globalPositionMock.accounts.map { $0.representable }
            operativeData.originAccountsNotVisibles = accounts
        }
        
        let publisher = sut.state
            .case { InternalTransferAccountSelectorState.loaded }
        sut.viewDidLoad()
        
        let result = try publisher.sinkAwait()
        XCTAssert(result.visible.isEmpty)
        XCTAssertFalse(result.notVisible.isEmpty)
    }
    
    func test_GivenSceneLaunchesAndAccountsAreLoaded_WhenNoAccountsAreProvided_Then_NoAccountsShouldBeSentToTheView() throws {
        setInDataBinding { _ in }
        
        let publisher = sut.state
            .case { InternalTransferAccountSelectorState.loaded }
        sut.viewDidLoad()
        
        let result = try publisher.sinkAwait()
        XCTAssert(result.visible.isEmpty)
        XCTAssert(result.notVisible.isEmpty)
    }
    
    func test_GivenNextIsExecuted_Then_TheOperativeShouldGoToNextStep() throws {
        setInDataBinding { _ in }
        
        sut.next()
        
        XCTAssert(operativeCoordinator.didGoNext)
    }
    
    func test_GivenAnAccountWasSelected_Then_OperativeDataHasAnOriginAccountSelected() throws {
        setInDataBinding { _ in }
        
        sut.didSelect(account: globalPositionMock.accounts[0].representable)
        
        let dataBinding: DataBinding = dependencies.resolve()
        let operativeData: InternalTransferOperativeData? = dataBinding.get()
        let accountOrigin = try XCTUnwrap(operativeData?.originAccount)
        XCTAssert(accountOrigin.equalsTo(other: globalPositionMock.accounts[0].representable))
    }
}

extension InternalTransferAccountSelectorViewModelTest {
    func defaultRegistration() {
        self.mockDataInjector.register(
            for: \.gpData.getGlobalPositionMock,
               filename: "obtenerPosGlobal"
        )
    }
    
    func getGlobalPositionMock() -> GlobalPositionMock {
        return GlobalPositionMock(
            self.mockDataInjector.mockDataProvider.gpData.getGlobalPositionMock,
            cardsData: [:],
            temporallyOffCards: [:],
            inactiveCards: [:],
            cardBalances: [:]
        )
    }
    
    func setInDataBinding(action: (InternalTransferOperativeData) -> Void) {
        let dataBinding: DataBinding = dependencies.resolve()
        let operativeData = InternalTransferOperativeData()
        action(operativeData)
        dataBinding.set(operativeData)
    }
    
    func filterAccounts() -> [AccountRepresentable] {
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }.dropLast()
        var filteredAccounts = [AccountRepresentable]()
        filteredAccounts.append(contentsOf: accounts)
        return filteredAccounts
    }
}

struct TestGlobalPositionDataRepository: GlobalPositionDataRepository {
    
    var accountRepresentables: [AccountRepresentable]
    
    init(accounts: [AccountRepresentable]) {
        self.accountRepresentables = accounts
    }
    
    func send(_ globalPosition: GlobalPositionDataRepresentable) {
        //
    }
    
    func getGlobalPosition() -> AnyPublisher<GlobalPositionDataRepresentable, Never> {
        return Just(MockGlobalPositionDataRepresentable(accounts: accountRepresentables)).eraseToAnyPublisher()
    }
    
    func send(_ mergedGlobalPosition: GlobalPositionAndUserPrefMergedRepresentable) {
        //
    }
    
    func getMergedGlobalPosition() -> AnyPublisher<GlobalPositionAndUserPrefMergedRepresentable, Never> {
        return Just(MockGlobalPositionAndUserPrefMergedRepresentable(accounts: accountRepresentables)).eraseToAnyPublisher()
    }
}
