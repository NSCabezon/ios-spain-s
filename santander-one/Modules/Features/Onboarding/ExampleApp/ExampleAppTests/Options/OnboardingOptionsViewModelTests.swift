//
//  OnboardingOptionsViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 13/1/22.
//

import XCTest
import OpenCombine
import CoreTestData
import CoreFoundationLib
import QuickSetup
import UnitTestCommons
import UI
@testable import Onboarding

final class OnboardingOptionsViewModelTests: XCTestCase {

    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingOptionsDependenciesResolver!
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    private var trackerManagerMock: TrackerManagerMock!
    
    override func setUpWithError() throws {
        externalDependenciesResolver = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingOptionsDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
                                                            externalDependencies: externalDependenciesResolver)
        stepsCoordinator = dependencies.resolve()
        let trackerManager: TrackerManager = externalDependenciesResolver.resolve()
        trackerManagerMock = trackerManager as? TrackerManagerMock
    }

    override func tearDownWithError() throws {
        externalDependenciesResolver = nil
        dependencies = nil
        stepsCoordinator = nil
        trackerManagerMock = nil
    }
    
    func test_viewDidLoad_success() throws {
        let sut = OnboardingOptionsViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingOptionsState.loadSections)
        sut.viewDidLoad()
        let sections = try publisher.sinkAwait()
        XCTAssertEqual(trackerManagerMock?.screenId, OnboardingOptions().page)
        XCTAssertNil(trackerManagerMock?.eventId)
        XCTAssertEqual(trackerManagerMock?.extraParameters, [:])
        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections.first?.items.first?.reuseIdentifier, "LocalizationOptionOnboardingView")
    }
    
    func test_viewWillAppear_success() throws {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        let sut = OnboardingOptionsViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.options)
    }
    
    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingOptionsViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: false))
            exp.fulfill()
        }
        sut.didAbortOnboarding(confirmed: true, deactivate: false)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
