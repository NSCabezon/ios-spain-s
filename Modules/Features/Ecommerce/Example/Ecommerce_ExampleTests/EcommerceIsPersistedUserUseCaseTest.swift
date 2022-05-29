//
//  EcommerceIsPersistedUserUseCase.swift
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

class EcommerceIsPersistedUserUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let appRepository: AppRepositoryMock = AppRepositoryMock()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTeardDown()
    }
    
    func test_useCase_withRequestValues_shouldBeOk() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
        let fakeRequestValues: Void = ()
        do {
            let response = try isPersistedUserUseCase(requestValues: fakeRequestValues)
            XCTAssertNotNil(try response.getOkResult())
        } catch {
            XCTFail("IsPersistedUserUseCase: throws")
        }
    }
    
    func test_useCase_withRequestValues_shouldBeError() {
        let fakeRequestValues: Void = ()
        do {
            let response = try isPersistedUserUseCase(requestValues: fakeRequestValues)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("IsPersistedUserUseCase: throws")
        }
    }
}

private extension EcommerceIsPersistedUserUseCaseTest {
    // MARK: - Setup
    func setTests() {
        setDependencies()
        setQuickSetup()
    }
    
    func setDependencies() {
        dependencies.register(for: BSANManagersProvider.self) { _ in
            self.quickSetup.managersProvider
        }
        dependencies.register(for: AppRepositoryProtocol.self) { _ in
            self.appRepository
        }
    }
    
    func setQuickSetup() {
        quickSetup = QuickSetup.shared
        quickSetup.setEnviroment(BSANEnvironments.enviromentPreWas9)
        quickSetup.doLogin(withUser: .demo)
    }
    
    func setTeardDown() {
        quickSetup.setDemoAnswers([:])
    }
    
    // MARK: - Prepare Test
    func isPersistedUserUseCase(requestValues: Void) throws -> UseCaseResponse<Void, StringErrorOutput> {
        let useCase = IsPersistedUserUseCase(dependenciesResolver: self.dependencies)
        let response = try useCase.executeUseCase(requestValues: requestValues)
        return response
    }
}
