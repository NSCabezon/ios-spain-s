//
//  EcommerceConfirmWithAccessKeyUseCaseTest.swift
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

class EcommerceConfirmWithAccessKeyUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTearDown()
    }
    
    func test_useCase_withShortUrlAndAccessKey_shouldBeOk() {
        quickSetup.setDemoAnswers(["autenticacion": 0])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "0", accessKey: "55555")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withEmptyShortUrlAndEmptyAccessKey_shouldBeOk() {
        quickSetup.setDemoAnswers(["autenticacion": 0])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "", accessKey: "")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withShortUrlAndAccessKey_shouldBeError403() {
        quickSetup.setDemoAnswers(["autenticacion": 1])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "1", accessKey: "55555")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withEmptyShortUrlAndEmptyAccessKey_shouldBeError403() {
        quickSetup.setDemoAnswers(["autenticacion": 1])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "", accessKey: "")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withShortUrlAndAccessKeyAndExpectedErrorResponse_shouldReturnErrorString() {
        quickSetup.setDemoAnswers(["autenticacion": 2])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "2", accessKey: "55555")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            let output = try response.getErrorResult()
            XCTAssert(output.getErrorDesc() != nil)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withEmptyShortUrlAndEmptyAccessKeyAndExpectedErrorResponse_shouldReturnErrorString() {
        quickSetup.setDemoAnswers(["autenticacion": 2])
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: "", accessKey: "")
        do {
            let response = try confirmWithAccessKeyUseCase(shortUrl: input.shortUrl, accessKey: input.accessKey)
            let output = try response.getErrorResult()
            XCTAssert(output.getErrorDesc() != nil)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
}

private extension EcommerceConfirmWithAccessKeyUseCaseTest {
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
    func confirmWithAccessKeyUseCase(shortUrl: String, accessKey: String) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let useCase = EcommerceConfirmWithAccessKeyUseCase(dependenciesResolver: self.dependencies)
        let input = EcommerceConfirmWithAccessKeyUseCaseInput(shortUrl: shortUrl, accessKey: accessKey)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}
