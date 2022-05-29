//
//  OnboardingWelcomeViewModelTest.swift
//  ExampleAppTests
//
//  Created by José Norberto Hidalgo Romero on 7/12/21.
//

import XCTest
import OpenCombine
import CoreTestData
import UnitTestCommons
import UI
@testable import Onboarding

class OnboardingWelcomeViewModelTest: XCTestCase {

    private var externalDependenciesResolver: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingWelcomeDependenciesResolver!
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    
    override func setUpWithError() throws {
        let externalDependencies = TestOnboardingExternalDependencies()
        externalDependenciesResolver = externalDependencies
        dependencies = TestOnboardingWelcomeDependencies(dependencies: TestOnboardingDependencies(external: externalDependenciesResolver),
                                                            externalDependencies: externalDependenciesResolver)
        stepsCoordinator = dependencies.resolve()
    }

    override func tearDownWithError() throws {
        externalDependenciesResolver = nil
        dependencies = nil
        stepsCoordinator = nil
    }
    
    func test_viewWillAppear_Success() {
        stepsCoordinator.next()
        let sut = OnboardingWelcomeViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        XCTAssertEqual(stepsCoordinator.current.type, OnboardingStep.welcome)
    }

    func test_onboardingWelcomeViewModel_whenGetUserInfo_shouldReturnName_LittleAlice() throws {
        let sut = OnboardingWelcomeViewModel(dependencies: dependencies)
        let publisher = sut.state
            .case(OnboardingWelcomeState.userInfoLoaded)
        sut.viewWillAppear()
        let userInfo = try publisher.sinkAwait()
        XCTAssertEqual(userInfo.name, "Little Alice")
    }

    func test_onboardingWelcomeViewModel_whenGetUserInfo_shouldReturnAlias_MyAlias() throws {
        let sut = OnboardingWelcomeViewModel(dependencies: dependencies)
        let publisher = sut.state
            .case(OnboardingWelcomeState.userInfoLoaded)
        sut.viewWillAppear()
        let userInfo = try publisher.sinkAwait()
        XCTAssertEqual(userInfo.alias, "MyAlias")
    }
    
    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        let sut = OnboardingWelcomeViewModel(dependencies: dependencies)
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: true))
            exp.fulfill()
        }
        sut.didAbortOnboarding(confirmed: true, deactivate: true)
        waitForExpectations(timeout: 2, handler: nil)
    }
}
