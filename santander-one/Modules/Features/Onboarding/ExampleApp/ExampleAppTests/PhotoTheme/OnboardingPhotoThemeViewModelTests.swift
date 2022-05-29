//
//  OnboardingPhotoThemeViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Camallonga on 17/12/21.
//

import Foundation
import XCTest
import CoreDomain
import CoreFoundationLib
import OpenCombine
@testable import Onboarding
import QuickSetup
import UI
import CoreTestData
import UnitTestCommons

final class OnboardingPhotoThemeViewModelTests: XCTestCase {
    
    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingPhotoThemeDependenciesResolver!
    private var anySubscriptions: Set<AnyCancellable> = []
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    private var trackerManagerMock: TrackerManagerMock!
    
    override func setUpWithError() throws {
        externalDependenciesResolver = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingPhotoThemeDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
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
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingPhotoThemeState.info)
        sut.viewDidLoad()
        let values = try publisher.sinkAwait()
        XCTAssertEqual(values.info.count, 7)
        XCTAssertEqual(values.info.first?.title.text, localized("onboarding_title_geographic"))
        XCTAssertEqual(values.info.first?.description.text, localized("onboarding_text_geographic"))
        XCTAssertEqual(values.titleKey, "onboarding_text_chooseSubject")
        XCTAssertEqual(values.bannedIndexes.count, 0)
    }
    
    func test_didScrollToNewOption_success() {
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.didScrollToNewOption()
        XCTAssertEqual(trackerManagerMock?.screenId, OnboardingPhoto().page)
        XCTAssertEqual(trackerManagerMock?.eventId, OnboardingPhoto.Action.swipe.rawValue)
        XCTAssertEqual(trackerManagerMock?.extraParameters, [:])
    }
    
    func test_didSelectNext_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        stepsCoordinator.next() // .photoTheme
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.didSelectNext(optionSelected: 1)
        XCTAssertEqual(trackerManagerMock?.screenId, OnboardingPhoto().page)
        XCTAssertEqual(trackerManagerMock?.eventId, OnboardingPhoto.Action.continueAction.rawValue)
        XCTAssertEqual(trackerManagerMock?.extraParameters,
                       [TrackerDimension.photoType.key: BackgroundImagesTheme(id: PhotoThemeOption.pets.value())?.trackName ?? ""])
    }
    
    func test_didSelectBack_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        stepsCoordinator.next() // .photoTheme
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        sut.didSelectBack()
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.selectPG)
    }
    
    func test_didCloseError_success() {
        stepsCoordinator.next() // .welcome
        stepsCoordinator.next() // .languages
        stepsCoordinator.next() // .options
        stepsCoordinator.next() // .selectPG
        stepsCoordinator.next() // .photoTheme
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        sut.didCloseError()
        XCTAssertEqual(stepsCoordinator.current.type, Onboarding.OnboardingStep.final)
    }
    
    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingPhotoThemeViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: false))
            exp.fulfill()
        }
        sut.didAbortOnboarding(confirmed: true, deactivate: false)
        waitForExpectations(timeout: 2, handler: nil)
    }
}

private extension OnboardingPhotoThemeViewModelTests {
    func waitForHideLoading(sut: OnboardingPhotoThemeViewModel) {
        let exp = expectation(description: "Await for hideLoading state")
        sut.state.sink(receiveValue: { value in
            guard case .hideLoading = value else { return }
            exp.fulfill()
        }).store(in: &anySubscriptions)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
