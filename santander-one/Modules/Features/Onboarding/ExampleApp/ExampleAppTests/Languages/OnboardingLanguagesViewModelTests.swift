//
//  OnboardingLanguagesViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 14/12/21.
//

import XCTest
import OpenCombine
import CoreTestData
import CoreFoundationLib
import QuickSetup
import UnitTestCommons
import UI
@testable import Onboarding

final class OnboardingLanguagesViewModelTests: XCTestCase {
   
    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingLanguagesDependenciesResolver!
    private var anySubscriptions: Set<AnyCancellable> = []
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    private var trackerManagerMock: TrackerManagerMock!
    
    override func setUpWithError() throws {
        externalDependenciesResolver = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingLanguagesDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
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
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingLanguagesState.values)
        sut.viewDidLoad()
        let values = try publisher.sinkAwait()
        let expected = [LanguageType.spanish.languageName, LanguageType.english.languageName, LanguageType.french.languageName]
        XCTAssertEqual(values.items.map { $0.value }, expected)
        XCTAssertNil(values.languageSelected)
    }
    
    func test_viewWillAppear_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        XCTAssertEqual(trackerManagerMock?.screenId, OnboardingLanguage().page)
        XCTAssertNil(trackerManagerMock?.eventId)
        XCTAssertEqual(trackerManagerMock?.extraParameters, [:])
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.languages)
    }
    
    func test_setLanguage_success() throws {
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingLanguagesState.values)
        sut.viewDidLoad()
        sut.setLanguage(.french)
        let values = try publisher.sinkAwait()
        XCTAssertEqual(values.languageSelected, .french)
    }
    
    func test_didSelectNext_success() throws {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        let languageSelected = LanguageType.french
        let publisher = sut.state.case(OnboardingLanguagesState.values)
        sut.viewDidLoad()
        _ = try publisher.sinkAwait()
        sut.setLanguage(languageSelected)
        sut.didSelectNext()
        waitForShowLoading(sut: sut)
    }
    
    func test_didSelectBack_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        sut.didSelectBack()
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.welcome)
    }
    
    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingLanguagesViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: true))
            exp.fulfill()
        }
        sut.didAbortOnboarding(confirmed: true, deactivate: true)
        waitForExpectations(timeout: 2, handler: nil)
    }
}

private extension OnboardingLanguagesViewModelTests {
    func waitForShowLoading(sut: OnboardingLanguagesViewModel) {
        let exp = expectation(description: "Await for showLoading state")
        sut.state.sink(receiveValue: { value in
            guard case .showLoading = value else { return }
            exp.fulfill()
        }).store(in: &anySubscriptions)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
