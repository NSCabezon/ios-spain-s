//
//  InternalTransferConfirmationViewModelTest.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Juan Sánchez Marín on 16/3/22.
//

import XCTest
import OpenCombine
import CoreFoundationLib
import CoreTestData
import CoreDomain
import UnitTestCommons

@testable import TransferOperatives

class InternalTransferConfirmationViewModelTest: XCTestCase {
    var dependencies: InternalTransferConfirmationDependenciesResolver!
    var externalDependencies: TestInternalTransferConfirmationExternalDependencies!
    private var trackerManager: TrackerManagerMock!
    private var mockDataInjector = MockDataInjector()
    private var globalPositionMock: GlobalPositionRepresentable!
    private var operativeDependencies: TestInternalTransferOperativeDependencies!
    private var operativeCoordinator: InternalTransferOperativeCoordinatorMock!
    private var sut: InternalTransferConfirmationViewModel!

    override func setUp() {
        defaultRegistration()
        trackerManager = TrackerManagerMock()
        globalPositionMock = getGlobalPositionMock()
        operativeDependencies = TestInternalTransferOperativeDependencies()
        operativeCoordinator = InternalTransferOperativeCoordinatorMock(dependencies: operativeDependencies)
        externalDependencies = TestInternalTransferConfirmationExternalDependencies(trackerManager: trackerManager)
        dependencies = TestInternalTransferConfirmationDependencies(externalDependencies: externalDependencies, operativeCoordinator: operativeCoordinator)
        operativeDependencies.coordinator = operativeCoordinator
        sut = InternalTransferConfirmationViewModel(dependencies: dependencies)
        setDataBinding()
    }

    override func tearDownWithError() throws {
        dependencies = nil
    }

    func test_Given_AmountAndFlowItems_When_LoadedStateIsCalled_Then_AmountIsnotNil() throws {
        let publisher = sut.state
        .case(InternalTransferConfirmationState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.ammount)
    }

    func test_Given_AmountAndFlowItems_When_LoadedStateIsCalled_Then_FlowItemsIsnotNil() throws {
        let publisher = sut.state
        .case(InternalTransferConfirmationState.loaded)
        sut.viewDidLoad()
        let result = try publisher.sinkAwait()
        XCTAssertNotNil(result.flowItems)
    }
}

extension InternalTransferConfirmationViewModelTest {
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

    func setDataBinding() {
        let dataBinding: DataBinding = dependencies.resolve()
        let operativeData = InternalTransferOperativeData()
        let accounts = globalPositionMock.accounts.map { entity in
            entity.representable
        }
        operativeData.originAccount = accounts[0]
        operativeData.destinationAccount = accounts[1]
        operativeData.amount = AmountRepresented(value: 5, currencyRepresentable: CurrencyRepresented(currencyName: CurrencyType.złoty.name, currencyCode: "PLN"))
        dataBinding.set(operativeData)
    }
}
