//
//  TimeSelectorViewModelTest.swift
//  Menu_ExampleTests
//
//  Created by Jose Javier Montes Romero on 7/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import UnitTestCommons
import QuickSetup
import CoreFoundationLib
import CoreDomain
@testable import Menu

final class TimeSelectorViewModelTest: XCTestCase {
    private lazy var dependencies: TimeSelectorDependenciesResolverMock = {
        let external = TimeSelectorExternalDependenciesResolverMock(oldDependencies: self.oldDependencies)
        return TimeSelectorDependenciesResolverMock(external: external)
    }()
    private var oldDependencies: (DependenciesInjector & DependenciesResolver)!
    private var trackManager: TrackerManagerMock!
    private var coordinator: TimeSelectorCoordinatorMock!

    private var defatulCurrenTimeSelector: TimeSelectorRepresentable? {
        return DefatultTimeSelectorModel()
    }
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        oldDependencies = DependenciesDefault()
        trackManager = TrackerManagerMock()
        coordinator = TimeSelectorCoordinatorMock(dependencies: self.dependencies)
        dependencies.coordinator = coordinator
    }

    func test_WhenExecutedTimeSelectorScreen_And_The_SelectedTime_Is_Not_Customized() throws {
        // Set a time selected different to Customized
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(TimeSelectorState.updateTimeViewSelected)
        let result = try publisher.sinkAwait()

        XCTAssertEqual(result, self.defatulCurrenTimeSelector!.timeViewSelected)
    }
    
    func test_WhenExecutedTimeSelectorScreen_And_The_SelectedTime_Is_Customized() throws {
        // Set a time selected to Customized
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.didTapOnTimeView(index: TimeViewOptions.customized.elementIndex())
        sut.viewDidLoad()
        let publisher = sut.state
            .case(TimeSelectorState.updateTimeViewSelected)
        let resultTimeSelected = try publisher.sinkAwait()

        XCTAssertEqual(resultTimeSelected, .customized)
    }
    
//    func test_WhenExecutedShowMenu_ThenCoordinatorShownMenu() {
//        let sut = TimeSelectorViewModel(dependencies: dependencies)
//        sut.openPrivateMenu()
//        XCTAssert(coordinator.didOpenMenu)
//    }
    
    func test_WhenExecutedConfirmButton_ThenCoordinatorSendData_AndGoBack() {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.didTapConfirm()
        XCTAssert(coordinator.didDismiss)
    }
    
    func test_WhenSelectedNewStartDate_ThenConfirmButtonShouldBeShown() throws {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        let newStartDate = Date(timeIntervalSinceNow: 0)
        sut.didStartDateChanged(newStartDate)
        let publisher = sut.state
            .case(TimeSelectorState.isEnableConfirmDates)
        let result = try publisher.sinkAwait()
        
        XCTAssert(result)
    }
    
    func test_WheSelectedNewTimeOption_AndIsNotCustomized_ThenCoordinatorDoDismiss() throws {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.didTapOnTimeView(index: TimeViewOptions.mounthly.elementIndex())
        XCTAssert(coordinator.didDismiss)
    }
    
    func test_WheSelectedNewTimeOption_AndIsCustomized_AndNotHaveStartDateSelected_ThenConfirmButtonShouldBeInactive() throws {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.didTapOnTimeView(index: TimeViewOptions.customized.elementIndex())
        let publisher = sut.state
            .case(TimeSelectorState.isEnableConfirmDates)
        let result = try publisher.sinkAwait()
        XCTAssertFalse(result)
        XCTAssertFalse(coordinator.didDismiss)
    }
    
    func test_WheSelectedNewTimeOption_AndIsCustomized_AndNotHaveStartDateSelected_ThenConfirmButtonShouldBeActive() throws {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        sut.didStartDateChanged(Date.init(timeIntervalSinceNow: 0))
        sut.didTapOnTimeView(index: TimeViewOptions.customized.elementIndex())
        let publisher = sut.state
            .case(TimeSelectorState.isEnableConfirmDates)
        let result = try publisher.sinkAwait()
        XCTAssert(result)
        XCTAssertFalse(coordinator.didDismiss)
    }
    
    func test_WhenExecutedTimeSelectorScreen_AndThereIsStartDateSelected() throws {
        let sut = TimeSelectorViewModel(dependencies: dependencies)
        let startDate = Date.init(timeIntervalSinceNow: 0)
        sut.didStartDateChanged(startDate)
        sut.viewDidLoad()
        let publisher = sut.state
            .case(TimeSelectorState.updateSelectedDates)
        let result = try publisher.sinkAwait()
        XCTAssertEqual(startDate, result.startDate)
    }
}
