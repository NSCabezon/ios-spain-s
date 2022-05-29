//
//  EcommerceGetPushNotificationUseCaseTest.swift
//  Ecommerce_ExampleTests
//
//  Created by Ignacio González Miró on 11/3/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLibraryV3
import CoreTestData
@testable import Ecommerce

class EcommerceGetPushNotificationUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let appConfigRepository: AppConfigRepositoryProtocol = MockAppConfigRepository(mockDataInjector: MockDataInjector(mockDataProvider: MockDataProvider()))
    private let appRepository: AppRepositoryMock = AppRepositoryMock()
    private var quickSetup: QuickSetup!

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTeardDown()
    }
    
    func test_useCase_withoutPersistedUser_shouldBeErrorWithOutputNil() {
        let fakeRequestValues: Void = ()
        do {
            let response = try getEcommercePushNotificationUseCase(fakeRequestValues)
            let output = try response.getErrorResult()
            XCTAssertNil(output.getErrorDesc())
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
    
    func test_useCase_withPersistedUserAndUserIdNil_shouldBeError() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: nil, biometryData: nil))
        let fakeRequestValues: Void = ()
        do {
            let response = try getEcommercePushNotificationUseCase(fakeRequestValues)
            XCTAssert(!response.isOkResult)
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
    
    func test_useCase_withPersistedUserAndUserIdNotNil_shouldBeOk() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
        let fakeRequestValues: Void = ()
        do {
            let response = try getEcommercePushNotificationUseCase(fakeRequestValues)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
    
    func test_useCase_withNotificationPushNotNil_shouldBeOk() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
        let sentDate = Date().toLocalTime()
        setPersistedEcommerceNotification(sentDate)
        let fakeRequestValues: Void = ()
        do {
            let response = try getEcommercePushNotificationUseCase(fakeRequestValues)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
    
    func test_useCase_withNotificationPushNotNilAndRemainingSecondBiggerThatMaxMinutes_shouldBeOk() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
        let sentDate = Date().addDay(days: -1).toLocalTime()
        setPersistedEcommerceNotification(sentDate)
        let fakeRequestValues: Void = ()
        do {
            let response = try getEcommercePushNotificationUseCase(fakeRequestValues)
            let output = try response.getOkResult()
            XCTAssert(output.lastPurchaseInfo == EcommerceLastPurchaseInfo(code: "0", remainingTime: nil))
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
}

private extension EcommerceGetPushNotificationUseCaseTest {
    // MARK: - Setup
    func setTests() {
        setDependencies()
        setQuickSetup()
    }
    
    func setDependencies() {
        dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            self.appConfigRepository
        }
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
    
    // MARK: - Prepare test
    func getEcommercePushNotificationUseCase(_ requestValues: Void) throws -> UseCaseResponse<GetEcommercePushNotificationUseCaseOkOutput, StringErrorOutput> {
        let useCase = GetEcommercePushNotificationUseCase(dependenciesResolver: self.dependencies)
        let response = try useCase.executeUseCase(requestValues: requestValues)
        return response
    }
    
    func setPersistedEcommerceNotification(_ sentDate: Date) {
        let userPref = appRepository.getUserPreferences(userId: "demo")
        userPref.ecommercePushNotification = TwinpushPersistedNotification(code: "0", sentDate: sentDate)
        appRepository.setUserPreferences(userPref: userPref)
    }
}
