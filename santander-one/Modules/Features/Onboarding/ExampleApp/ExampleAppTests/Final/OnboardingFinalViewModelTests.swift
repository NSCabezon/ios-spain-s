//
//  OnboardingFinalViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 10/1/22.
//

import XCTest
import CoreDomain
import CoreFoundationLib
import CoreTestData
import OpenCombine
import QuickSetup
import UI
import UnitTestCommons
@testable import Onboarding

class OnboardingFinalViewModelTests: XCTestCase {

    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingFinalDependenciesResolver!
    private var anySubscriptions: Set<AnyCancellable> = []
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    private var trackerManagerMock: TrackerManagerMock!
    private var quickSetupForCoreTestData: QuickSetupForCoreTestData!
    
    override func setUpWithError() throws {
        let externalDependencies = TestOnboardingExternalDependencies()
        externalDependenciesResolver = externalDependencies
        dependencies = TestOnboardingFinalDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
                                                            externalDependencies: externalDependenciesResolver)
        stepsCoordinator = dependencies.resolve()
        let trackerManager: TrackerManager = externalDependenciesResolver.resolve()
        trackerManagerMock = trackerManager as? TrackerManagerMock
        let data = QuickSetupForCoreTestData()
        data.registerDependencies(in: externalDependencies.dependenciesResolver)
        quickSetupForCoreTestData = data
    }

    override func tearDownWithError() throws {
        externalDependenciesResolver = nil
        dependencies = nil
        stepsCoordinator = nil
        trackerManagerMock = nil
        quickSetupForCoreTestData = nil
    }
    
    func test_viewDidLoad_success() throws {
        quickSetupForCoreTestData.mockDataInjector.register(for: \.gpData.getGlobalPositionMock, filename: "obtenerPosGlobal")
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingFinalState.navigationItems)
        sut.viewDidLoad()
        let values = try publisher.sinkAwait()
        XCTAssertFalse(values.allowAbort)
        XCTAssertNil(values.currentPosition)
        XCTAssertNil(values.total)
    }
    
    func test_viewDidAppear_success() throws {
        quickSetupForCoreTestData.mockDataInjector.register(for: \.gpData.getGlobalPositionMock, filename: "obtenerPosGlobal")
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingFinalState.digitalProfile)
        sut.viewDidAppear()
        let percentage = try publisher.sinkAwait()
        XCTAssertEqual(Int(percentage), 45)
    }
    
    func test_viewWillAppear_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        stepsCoordinator.next() // .photoTheme
        stepsCoordinator.next() // .final
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        XCTAssertEqual(trackerManagerMock?.screenId, OnboardingFinal().page)
        XCTAssertNil(trackerManagerMock?.eventId)
        XCTAssertEqual(trackerManagerMock?.extraParameters, [:])
        XCTAssertEqual(stepsCoordinator.current.type, OnboardingStep.final)
    }
    
    func test_didPressedContinueDigitalProfile_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .digitalProfile)
            exp.fulfill()
        }
        sut.didPressedContinueDigitalProfile()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_didSelectNext_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .onboardingFinished)
            exp.fulfill()
        }
        sut.didSelectNext()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_didSelectBack_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        stepsCoordinator.next() // .photoTheme
        stepsCoordinator.next() // .final
        let sut = OnboardingFinalViewModel(dependencies: dependencies)
        sut.didSelectBack()
        XCTAssertEqual(stepsCoordinator.current.type, OnboardingStep.photoTheme)
    }
}
