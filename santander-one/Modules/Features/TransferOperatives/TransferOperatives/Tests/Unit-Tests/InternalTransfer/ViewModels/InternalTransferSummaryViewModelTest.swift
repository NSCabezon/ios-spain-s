//
//  InternalTransferSummaryViewModelTest.swift
//  TransferOperatives-Unit-Tests
//
//  Created by Mario Rosales Maillo on 24/3/22.
//

import XCTest
import OpenCombine
import CoreFoundationLib
import CoreTestData
import CoreDomain
import UnitTestCommons

@testable import TransferOperatives

class InternalTransferSummaryViewModelTest: XCTestCase {
    
    let expectation = XCTestExpectation(description: "AlertItemLoaded")
    var dependencies: InternalTransferSummaryDependenciesResolver!
    private var mockDataInjector = MockDataInjector()
    private var globalPosition: GlobalPositionRepresentable!
    private var subscriptions: Set<AnyCancellable> = []
    private var sut: InternalTransferSummaryViewModel!
    private let modifier =  TestInternalTransferSummaryModifier()
        
    override func setUp() {
        defaultRegistration()
        globalPosition = getGlobalPositionMock()
        dependencies = TestInternalTransferSummaryDependenciesResolver(externalDependencies: TestInternalTransferSummaryExternalDependenciesResolver(modifier: modifier))
        sut = InternalTransferSummaryViewModel(dependencies: dependencies)
        setDataBinding()
    }

    override func tearDownWithError() throws {
        dependencies = nil
    }
    
    func test_Given_OriginAndDestinationAccount_When_SummaryItemsLoaded_Then_FourItemsShouldLoad() throws {
        let trigger = { [unowned self ] in self.sut.viewDidLoad() }
        let publisher = sut.state
            .case(InternalTransferSummaryState.summaryItemsLoaded)
        let result = try publisher.sinkAwait(beforeWait: trigger)
        XCTAssertTrue(result.count == 4)
    }
    
    func test_Given_Amount_When_HeaderLoaded_Then_ValueIsNotNil() throws {
        let trigger = { [unowned self ] in self.sut.viewDidLoad() }
        let publisher = sut.state
            .case(InternalTransferSummaryState.headerLoaded)
        let result = try publisher.sinkAwait(beforeWait: trigger)
        XCTAssertNotNil(result.value)
    }
    
    func test_Given_OriginAndDestinationAccount_When_FooterLoaded_Then_ThreeElementsShouldLoad() throws {
        let trigger = { [unowned self ] in self.sut.viewDidLoad() }
        let publisher = sut.state
            .case(InternalTransferSummaryState.footerLoaded)
        let result = try publisher.sinkAwait(beforeWait: trigger)
        XCTAssertTrue(result.elements.count == 3)
    }
    
    func test_Given_OriginAndDestinationAccount_When_SharingLoaded_Then_TwoElementsShouldLoad() throws {
        let trigger = { [unowned self ] in self.sut.viewDidLoad() }
        let publisher = sut.state
            .case(InternalTransferSummaryState.sharingLoaded)
        let result = try publisher.sinkAwait(beforeWait: trigger)
        XCTAssertTrue(result.count == 2)
    }
    
    func test_Given_NonFreeInternalTransfer_When_AlertItemLoaded_Then_AlertConfigurationIsNotNil() throws {
        let trigger = { [unowned self ] in self.sut.viewDidLoad() }
        let publisher = sut.state
            .case(InternalTransferSummaryState.alertItemLoaded)
        let result = try publisher.sinkAwait(beforeWait: trigger)
        XCTAssertNotNil(result.additionalFeeIconKey)
        XCTAssertNotNil(result.additionalFeeKey)
        XCTAssertNotNil(result.additionalFeeLinkKey)
        XCTAssertNotNil(result.additionalFeeKey)
    }
    
    func test_Given_FreeInternalTransfer_Then_AlertItemLoadedIsNotCalled() throws {
        let timeInSeconds = 3.0
        modifier.isFreeTransferShouldReturn = true
        sut.state
            .case(InternalTransferSummaryState.alertItemLoaded)
            .sink { _ in
                XCTFail()
            }.store(in: &subscriptions)
        sut.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInSeconds) { [unowned self] in
            self.expectation.fulfill() }
        wait(for: [expectation], timeout: timeInSeconds + 1.0)
        XCTAssert(modifier.isFreeTransferShouldReturn)
    }
}

extension InternalTransferSummaryViewModelTest {
    
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
        let accounts = globalPosition.accounts.map { entity in
            entity.representable
        }
        operativeData.originAccount = accounts[0]
        operativeData.destinationAccount = accounts[1]
        operativeData.amount = accounts[0].availableAmount
        dataBinding.set(operativeData)
    }
}
