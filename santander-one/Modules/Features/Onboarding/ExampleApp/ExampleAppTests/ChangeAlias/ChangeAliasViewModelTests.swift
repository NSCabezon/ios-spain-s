//
//  ChangeAliasViewModelTests.swift
//  ExampleAppTests
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import Foundation
import XCTest
import OpenCombine
import CoreTestData
import CoreDomain
import UnitTestCommons
import QuickSetup
import UI
@testable import Onboarding

class ChangeAliasViewModelTest: XCTestCase {
    
    private var externalDependencies: OnboardingExternalDependenciesResolver!
    private var dependencies: OnboardingChangeAliasDependenciesResolver!
    private var stepsCoordinator: StepsCoordinator<OnboardingStep>!
    
    override func setUpWithError() throws {
        externalDependencies = TestOnboardingExternalDependencies()
        dependencies = TestOnboardingChangeAliasDependencies(dependencies: TestOnboardingDependencies(external: externalDependencies),
                                                            externalDependencies: externalDependencies)
        stepsCoordinator = dependencies.resolve()
    }

    override func tearDownWithError() throws {
        externalDependencies = nil
        dependencies = nil
        stepsCoordinator = nil
    }
    
    func test_changeAliasViewModel_whenViewDidLoad_shouldLoadAlias_MyAlias() throws {
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingChangeAliasState.aliasLoaded)
        sut.viewWillAppear()
        let alias = try publisher.sinkAwait()
        XCTAssertEqual(alias, "MyAlias")
    }
    
    func test_changeAliasViewModel_whenNavigateToNextScreen_shouldUpdateAliasIfDifferent_newAlias() throws {
        let newAlias = "NewAlias"
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingChangeAliasState.aliasLoaded)
        sut.viewWillAppear()
        _ = try publisher.sinkAwait()
        sut.didSelectNext(newAlias: newAlias)
        let userPreferencesRepository: UserPreferencesRepository = dependencies.external.resolve()
        let mockedUserPreferencesRepository = userPreferencesRepository as? UserPreferencesRepositoryMock
        let updatedAlias = mockedUserPreferencesRepository?.spyUpdateUserPreferences?.alias
        XCTAssertEqual(newAlias, updatedAlias)
    }
    
    func test_changeAliasViewModel_whenNavigateToNextScreen_shouldNotUpdateAliasIfSame_nil() throws {
        let newAlias = "MyAlias"
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        let publisher = sut.state.case(OnboardingChangeAliasState.aliasLoaded)
        sut.viewWillAppear()
        _ = try publisher.sinkAwait()
        sut.didSelectNext(newAlias: newAlias)
        let userPreferencesRepository: UserPreferencesRepository = dependencies.external.resolve()
        let mockedUserPreferencesRepository = userPreferencesRepository as? UserPreferencesRepositoryMock
        let updatedAlias = mockedUserPreferencesRepository?.spyUpdateUserPreferences?.alias
        XCTAssertNil(updatedAlias)
    }
    
    func test_changeAliasViewModel_whenLanguageUpdated_shouldLoadAlias_MyAlias() throws {
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        sut.viewWillAppear()
        let languageManager: OnboardingLanguageManagerProtocol = dependencies.resolve()
        let publisher = sut.state.case(OnboardingChangeAliasState.aliasLoaded)
        languageManager.didLanguageUpdate.send()
        let alias = try publisher.sinkAwait()
        XCTAssertEqual(alias, "MyAlias")                
    }

    func test_didAbortOnboarding_success() {
        let coordinator: OnboardingCoordinator? = dependencies.resolve()
        let exp = expectation(description: "Correct onboarding termination")
        coordinator?.onFinish = {
            let termination: OnboardingTermination? = coordinator?.dataBinding.get()
            XCTAssertEqual(termination?.type, .cancelOnboarding(deactivate: false))
            exp.fulfill()
        }
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        sut.didAbortOnboarding(confirmed: true, deactivate: false)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func test_didSelectNext() {
        stepsCoordinator.next()
        stepsCoordinator.update(state: .enabled, for: .changeAlias)
        stepsCoordinator.next()
        let sut = OnboardingChangeAliasViewModel(dependencies: dependencies)
        sut.didSelectNext(newAlias: "NewAlias")
        XCTAssertEqual(stepsCoordinator.current.type, OnboardingStep.languages)
    }
}
