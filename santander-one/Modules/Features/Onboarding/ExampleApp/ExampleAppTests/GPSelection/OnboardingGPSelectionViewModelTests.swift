//
//  OnboardingGPSelectionViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Hidalgo on 14/12/21.
//

import XCTest
import OpenCombine
import CoreDomain
import CoreTestData
import CoreFoundationLib
import QuickSetup
import UnitTestCommons
import UI
@testable import Onboarding


final class OnboardingGPSelectionViewModelTests: XCTestCase {
    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingGPSelectionDependenciesResolver!
    private var anySubscriptions: Set<AnyCancellable> = []
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!

    
    override func setUpWithError() throws {
        externalDependenciesResolver = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingGPSelectionDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
                                                            externalDependencies: externalDependenciesResolver)
        stepsCoordinator = dependencies.resolve()
    }

    override func tearDownWithError() throws {
        externalDependenciesResolver = nil
        dependencies = nil
        stepsCoordinator = nil
    }
    
    func test_viewDidLoad_success() throws {
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        let values = try waitForValues(sut: sut)
        XCTAssertEqual(values?.info.first?.titleKey, nil)
        XCTAssertEqual(values?.titleKey, "onboarding_title_choosePg")
        XCTAssertEqual(values?.bannedIndexes, [])
    }
    
    func test_viewWillAppear_success() throws {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        let tracker: TrackerManager = dependencies.external.resolve()
        let trackerMock: TrackerManagerMock = try XCTUnwrap(tracker as? TrackerManagerMock)
        XCTAssertEqual(trackerMock.screenId, OnboardingPg().page)
        XCTAssertNil(trackerMock.eventId)
        XCTAssertEqual(trackerMock.extraParameters, [:])
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.selectPG)
    }
    
    func test_viewModel_didSelectNext_tracksEvent() throws {
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        let gpSelected = GlobalPositionOption.simple
        sut.viewDidLoad()
        sut.didSelectNext(gpSelected: gpSelected.rawValue, smartStyleSelected: nil)
        let tracker: TrackerManager = dependencies.external.resolve()
        let trackerMock: TrackerManagerMock = try XCTUnwrap(tracker as? TrackerManagerMock)
        XCTAssertEqual(trackerMock.screenId, OnboardingPg().page)
        XCTAssertEqual(trackerMock.eventId, OnboardingPg.Action.continueAction.rawValue)
        XCTAssertEqual(trackerMock.extraParameters, [TrackerDimension.pgType.key: gpSelected.trackName()])
    }
        
    func test_didSelectNext_updatesDifferentGP_updated() throws {
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        let gpSelected = GlobalPositionOption.simple
        sut.viewDidLoad()
        sut.didSelectNext(gpSelected: gpSelected.rawValue, smartStyleSelected: nil)
        let userPreferencesRepository: UserPreferencesRepository = dependencies.external.resolve()
        let userPreferencesMock: UserPreferencesRepositoryMock = try XCTUnwrap(userPreferencesRepository as? UserPreferencesRepositoryMock)
        XCTAssertEqual(userPreferencesMock.spyUpdateUserPreferences?.globalPositionOptionSelected?.rawValue, gpSelected.rawValue)
    }
    
    func test_didSelectNext_updatesSameGP_notUpdated() throws {
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        let gpSelected = GlobalPositionOption.classic
        sut.viewDidLoad()
        sut.didSelectNext(gpSelected: gpSelected.rawValue, smartStyleSelected: nil)
        let userPreferencesRepository: UserPreferencesRepository = dependencies.external.resolve()
        let userPreferencesMock: UserPreferencesRepositoryMock = try XCTUnwrap(userPreferencesRepository as? UserPreferencesRepositoryMock)
        XCTAssertNil(userPreferencesMock.spyUpdateUserPreferences)
    }
    
    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingGPSelectionViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: true))
            exp.fulfill()
        }
        sut.didAbortOnboarding(confirmed: true, deactivate: true)
        waitForExpectations(timeout: 2, handler: nil)
    }
}

private extension OnboardingGPSelectionViewModelTests {
    func waitForValues(sut: OnboardingGPSelectionViewModel) throws -> OnboardingGPSelectionStateInfo? {
        guard case let .showInfo(info) = try sut.state.sinkAwait() else {
            XCTFail()
            return nil
        }
        return info
    }
}
