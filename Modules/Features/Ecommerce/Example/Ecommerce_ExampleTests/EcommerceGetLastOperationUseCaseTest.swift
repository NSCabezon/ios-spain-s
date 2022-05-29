//
//  EcommerceGetLastOperationUseCaseTest.swift
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

class EcommerceGetLastOperationUseCaseTest: XCTestCase {
    private let dependencies: DependenciesResolver & DependenciesInjector = DependenciesDefault()
    private let appConfigRepository: AppConfigRepositoryProtocol = MockAppConfigRepository(mockDataInjector: MockDataInjector(mockDataProvider: MockDataProvider()))
    private let appRepository: AppRepositoryMock = AppRepositoryMock()
    private var quickSetup: QuickSetup!
    private let secondsInAMinute: Int = 60

    override func setUp() {
        setTests()
    }

    override func tearDown() {
        setTeardDown()
    }
    
    func test_useCase_withTokenDateInput_responseShouldBeOk() {
        quickSetup.setDemoAnswers(["sca-shorturl": 0])
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetLastOperationUseCase: throw")
        }
    }
    
    func test_useCase_withoutTokenDateInput_responseShouldBeError() {
        quickSetup.setDemoAnswers(["sca-shorturl": 0])
        do {
            let response = try getLastOperationUseCase(nil)
            XCTAssert(!response.isOkResult)
        } catch {
            XCTFail("GetLastOperationUseCase: throw")
        }
    }
    
    func test_useCase_withTokenDateInput_responseShouldBeError204() {
        quickSetup.setDemoAnswers(["sca-shorturl": 4])
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            XCTAssert(!response.isOkResult)
        } catch {
            XCTFail("GetLastOperationUseCase: throw")
        }
    }
    
    func test_useCase_withTokenDateInput_responseShouldBeError500() {
        quickSetup.setDemoAnswers(["sca-shorturl": 3])
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            XCTAssert(!response.isOkResult)
        } catch {
            XCTFail("GetLastOperationUseCase: throw")
        }
    }
    
    func test_useCase_withTokenDateInputAndNotificationIsUserPref_responseShouldBeOK() {
        quickSetup.setDemoAnswers(["sca-shorturl": 0])
        let sentDate = Date().toLocalTime()
        setPersistedEcommerceNotification(sentDate)
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            XCTAssert(response.isOkResult)
        } catch {
            XCTFail("GetLastOperationUseCase: throw")
        }
    }
    
    func test_useCase_withNotificationPushNotNilAndRemainingSecondBiggerThatMaxMinutes_shouldBeOk() {
        let sentDate = Date().addDay(days: -1).toLocalTime()
        setPersistedEcommerceNotification(sentDate)
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            let output = try response.getOkResult()
            XCTAssertNil(output.lastPurchaseInfo.remainingTime)
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
    
    func test_useCase_withoutNotificationPushNotNilAndRemainingSecondBiggerThatMaxMinutes_shouldBeOk() {
        setPersistedUser()
        let fakeTokenPush = Data()
        do {
            let response = try getLastOperationUseCase(fakeTokenPush)
            let output = try response.getOkResult()
            XCTAssertNil(output.lastPurchaseInfo.remainingTime)
        } catch {
            XCTFail("GetEcommercePushNotificationUseCase: throws")
        }
    }
}

private extension EcommerceGetLastOperationUseCaseTest {
    // MARK: - Setup
    func setTests() {
        setDependencies()
        setQuickSetup()
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
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
        quickSetup.setEnviroment(BSANEnvironments.environmentPre)
        quickSetup.doLogin(withUser: .demo)
    }
    
    func setTeardDown() {
        quickSetup.setDemoAnswers([:])
    }
    
    // MARK: - Preparing test
    func getLastOperationUseCase(_ tokenPushData: Data?) throws -> UseCaseResponse<EcommerceGetLastOperationUseCaseOutput, StringErrorOutput> {
        let useCase = EcommerceGetLastOperationUseCase(dependenciesResolver: self.dependencies)
        let input = EcommerceGetLastOperationUseCaseInput(tokenPush: tokenPushData)
        let response = try useCase.executeUseCase(requestValues: input)
        return response
    }
    
    func setPersistedEcommerceNotification(_ sentDate: Date) {
        guard let persistedUser = try? appRepository.getPersistedUser().getResponseData(),
              let userId = persistedUser.userId else {
            return
        }
        let userPref = appRepository.getUserPreferences(userId: userId)
        userPref.ecommercePushNotification = TwinpushPersistedNotification(code: "0", sentDate: sentDate)
        appRepository.setUserPreferences(userPref: userPref)
    }
    
    func setPersistedUser() {
        _ = appRepository.setPersistedUserDTO(persistedUserDTO: .createPersistedUser(touchTokenCiphered: nil, loginType: .U, login: "12345678z", environmentName: "", channelFrame: nil, isPb: true, name: nil, bdpCode: nil, comCode: nil, isSmart: true, userId: "demo", biometryData: nil))
        let userPref = appRepository.getUserPreferences(userId: "demo")
        appRepository.setUserPreferences(userPref: userPref)
    }
}
