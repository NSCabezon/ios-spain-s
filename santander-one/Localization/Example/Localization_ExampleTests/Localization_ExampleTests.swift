//
//  Localization_ExampleTests.swift
//  Localization_ExampleTests
//
//  Created by Francisco del Real Escudero on 11/6/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
import QuickSetup
@testable import Localization

class Localization_ExampleTests: XCTestCase {
    
    private var dependenciesEngine = DependenciesDefault()
    private var localAppConfig: LocalAppConfigMock = LocalAppConfigMock()
    private var useCase: GetLanguagesSelectionUseCaseMock!
    private var stringLoader: StringLoader!

    override func setUp() {
        self.registerDependencies()
        self.useCase = GetLanguagesSelectionUseCaseMock(dependencies: self.dependenciesEngine)
    }

    override func tearDownWithError() throws {
        self.dependenciesEngine.clean()
        self.useCase = nil
    }
    
    func testUsingDefaultLiteralsWhenTheLiteralDoesntExistInCurrentLanguageWithDefaultDifferentThanSpanish() {
        // Setup
        localAppConfig.language = .english
        useCase.updateOutput(language: Language.createFromType(languageType: .spanish, isPb: false), list: [.spanish, .english])
        let exp = expectation(description: "")
        
        // Operate
        let localeManager = Localization.LocaleManager(dependencies: self.dependenciesEngine)
        Async.after(seconds: 1) {
            let result = localeManager.getString("onboarding_text_helloThere").text
            
            XCTAssertEqual(result, "Hello there")
            exp.fulfill()
        }
        
        // Evaluate
        waitForExpectations(timeout: 2)
    }
    
    func testUsingDefaultLiteralsWhenTheLiteralDoesntExistInCurrentLanguage() {
        // Setup
        localAppConfig.language = .spanish
        useCase.updateOutput(language: Language.createFromType(languageType: .english, isPb: false), list: [.spanish, .english])
        let exp = expectation(description: "")
        
        // Operate
        let localeManager = LocaleManager(dependencies: self.dependenciesEngine)
        Async.after(seconds: 1) {
            let result = localeManager.getString("onboarding_link_notNow").text
            
            XCTAssertEqual(result, "Ahora no")
            exp.fulfill()
        }
        
        // Evaluate
        waitForExpectations(timeout: 2)
    }
    
    func testNotUsingCurrentLiteralWhenTheLiteralExistsInCurrentLanguage() {
        // Setup
        localAppConfig.language = .spanish
        useCase.updateOutput(language: Language.createFromType(languageType: .english, isPb: false), list: [.spanish, .english])
        let exp = expectation(description: "")
        
        // Operate
        let localeManager = LocaleManager(dependencies: self.dependenciesEngine)
        Async.after(seconds: 1) {
            let result = localeManager.getString("onboarding_text_callMeAnotherWay").text
            
            XCTAssertEqual(result, "Call me another way")
            exp.fulfill()
        }
        
        // Evaluate
        waitForExpectations(timeout: 2)
    }
    
    func testShowLiteralKeyWhenLiteralDoesntExistInCurrentAndInDefaultLanguages() {
        // Setup
        localAppConfig.language = .spanish
        useCase.updateOutput(language: Language.createFromType(languageType: .english, isPb: false), list: [.spanish, .english])
        let exp = expectation(description: "")
        
        // Operate
        let localeManager = LocaleManager(dependencies: self.dependenciesEngine)
        Async.after(seconds: 1) {
            let result = localeManager.getString("onboarding_text_ready").text
            
            XCTAssertEqual(result, "onboarding_text_ready")
            exp.fulfill()
        }
        
        // Evaluate
        waitForExpectations(timeout: 2)
    }

}

private extension Localization_ExampleTests {
    private func registerDependencies() {
        dependenciesEngine.register(for: GetLanguagesSelectionUseCaseProtocol.self) { resolver in
            return self.useCase
        }
        dependenciesEngine.register(for: UseCaseHandler.self) { resolver in
            return UseCaseHandler()
        }
        dependenciesEngine.register(for: LocalAppConfig.self) { resolver in
            return self.localAppConfig
        }
        dependenciesEngine.register(for: AppRepositoryProtocol.self) { resolver in
            return AppRepositoryMock()
        }
    }
}
