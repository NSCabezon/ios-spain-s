//
//  EcommerceGetOperationDataUseCaseTest.swift
//  Ecommerce_ExampleTests
//
//  Created by Ignacio González Miró on 11/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
@testable import Ecommerce

class EcommerceGetOperationDataUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTeardDown()
    }
    
    func test_useCase_withLastOperationCodeInput_shouldBeOk() {
        quickSetup.setDemoAnswers(["datosOperacion": 0])
        do {
            let response = try getOperationDataUseCase("0")
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetOperationDataUseCase: throws")
        }
    }
    
    func test_useCase_withEmptyLastOperationCodeInput_shouldBeError400() {
        quickSetup.setDemoAnswers(["datosOperacion": 1])
        do {
            let response = try getOperationDataUseCase("1")
            XCTAssert(!response.isOkResult)
        } catch {
            XCTFail("GetOperationDataUseCase: throws")
        }
    }
}

private extension EcommerceGetOperationDataUseCaseTest {
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
        quickSetup.setEnviroment(BSANEnvironments.environmentPre)
        quickSetup.doLogin(withUser: .demo)
    }
    
    func setTeardDown() {
        quickSetup.setDemoAnswers([:])
    }
    
    // MARK: - Prepare test
    func getOperationDataUseCase(_ ecommerceLastOperationCode: String) throws -> UseCaseResponse<EcommerceGetOperationDataUseCaseOutput, StringErrorOutput> {
        let useCase = EcommerceGetOperationDataUseCase(dependenciesResolver: self.dependencies)
        let input = EcommerceGetOperationDataUseCaseInput(ecommerceLastOperationCode: ecommerceLastOperationCode)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
}
