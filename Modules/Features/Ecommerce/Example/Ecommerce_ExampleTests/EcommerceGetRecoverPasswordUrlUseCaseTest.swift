//
//  EcommerceGetRecoverPasswordUrlUseCase.swift
//  Ecommerce_ExampleTests
//
//  Created by Ignacio González Miró on 29/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
@testable import Ecommerce

class EcommerceGetRecoverPasswordUrlUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTearDown()
    }

    func test_useCase_withRequestValues_shouldBeOk() {
        let fakeRequestValues: Void = ()
        do {
            let response = try getRecoveryPasswordUseCase(requestValues: fakeRequestValues)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetRecoveryPasswordUseCase: throws")
        }
    }
    
    func test_useCase_withRequestValues_shouldBeError() {
        let fakeRequestValues: Void = ()
        do {
            let response = try getRecoveryPasswordUseCase(requestValues: fakeRequestValues)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetRecoveryPasswordUseCase: throws")
        }
    }
}

private extension EcommerceGetRecoverPasswordUrlUseCaseTest {
    // MARK: - Setup
    func setTests() {
        setDependencies()
        setQuickSetup()
    }
    
    func setDependencies() {
        dependencies.register(for: BSANManagersProvider.self) { _ in
            self.quickSetup.managersProvider
        }
    }
    
    func setQuickSetup() {
        quickSetup = QuickSetup.shared
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
    }
    
    func setTearDown() {
        quickSetup.setDemoAnswers([:])
    }
    
    // MARK: - Prepare Test
    func getRecoveryPasswordUseCase(requestValues: Void) throws -> UseCaseResponse<GetRecoverPasswordUrlUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetRecoverPasswordUrlUseCase(dependenciesResolver: self.dependencies)
        let response = try useCase.executeUseCase(requestValues: requestValues)
        return response
    }
}
