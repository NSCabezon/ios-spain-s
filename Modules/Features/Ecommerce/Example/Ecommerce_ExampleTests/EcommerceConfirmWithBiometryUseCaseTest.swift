//
//  EcommerceConfirmWithBiometryUseCaseTest.swift
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

class EcommerceConfirmWithBiometryUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTearDown()
    }

    func test_useCase_withShortUrlOkAndEmptyFingerprintAndDevicetoken_shouldBeOk() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 0])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "0", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withoutShortUrlEmptyFingerprintAndEmptydDevicetoken_shouldBeOk() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 0])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }

    func test_useCase_withShortUrlError1AndEmptyFingerprintAndDevicetoken_shouldBeError403() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 1])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "1", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withoutShortUrlEmptyFingerprintAndEmptydDevicetoken_shouldBeError403() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 1])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withShortUrl2AndEmptyFingerprintAndDevicetokenAndExpectedErrorResponse_shouldReturnErrorString() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 2])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "2", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            let output = try response.getErrorResult()
            XCTAssert(output.getErrorDesc() != nil)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
    
    func test_useCase_withoutShortUrl2AndEmptyFingerprintAndDevicetokenAndExpectedErrorResponse_shouldReturnErrorString() {
        quickSetup.setDemoAnswers(["fingerprint-authentication": 2])
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: "", fingerprint: "", deviceToken: "")
        do {
            let response = try confirmWithBiometryUseCase(shortUrl: input.shortUrl, fingerprint: input.fingerprint, deviceToken: input.deviceToken)
            let output = try response.getErrorResult()
            XCTAssert(output.getErrorDesc() != nil)
        } catch {
            XCTFail("EcommerceConfirmWithAccessKeyUseCase: throws")
        }
    }
}

private extension EcommerceConfirmWithBiometryUseCaseTest {
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
    func confirmWithBiometryUseCase(shortUrl: String, fingerprint: String, deviceToken: String) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let useCase = EcommerceConfirmWithBiometryUseCase(dependenciesResolver: self.dependencies)
        let input = EcommerceConfirmWithBiometryUseCaseInput(shortUrl: shortUrl, fingerprint: fingerprint, deviceToken: deviceToken)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}
