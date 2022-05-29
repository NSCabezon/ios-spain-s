//
//  GetRecoveryLevelUseCaseTest.swift
//  ExampleAppTests
//
//  Created by César González Palomino on 03/11/2020.
//  Copyright © 2020 Jose Carlos Estela Anguita. All rights reserved.
//

import XCTest
import CoreFoundationLib
import UnitTestCommons
import UI
import SANLegacyLibrary
import CoreTestData
import Fuzi
@testable import GlobalPosition

final class GetRecoveryLevelUseCaseTest: XCTestCase {
    
    private let dependencies: DependenciesResolver & DependenciesInjector =  DependenciesDefault()
    private let mockDataInjector = MockDataInjector()
    
    override func setUp() {
        
        self.dependencies.register(for: SANLegacyLibrary.BSANManagersProvider.self) { _ in
            MockBSANManagersProvider.build(from: self.mockDataInjector)
        }
        
        self.dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
    }
    
    func test_execute_withAppConfigEnabled_AndUserWithInValidRecoveryCampaigns_responseShouldBeFailure() {
        guard
            let response = setupUseCaseResponse(answerResponse: ConstantsTest.aviso3_variosProductos,
                                                appconfig: ["campaignsRecoveryPG": "['2', '4', '8']"])
        else { XCTFail("unable to create response"); return }
        XCTAssert(response.isOkResult == false, "Response should be Failure when user campaigns does not match")
    }
    
    func test_execute_withAppConfigEnabled_AndUserWithValidNoticesAndValidRecoveryCampaigns_responseShouldBeOK() {
        guard
            let response = setupUseCaseResponse(answerResponse: ConstantsTest.aviso3_variosProductos,
                                                appconfig: ["campaignsRecoveryPG": "['529', '4']"])
        else { XCTFail("unable to create response"); return }
        XCTAssert(response.isOkResult == true, "Response should be Ok when node is enabled")
    }
    
    func test_execute_withAppConfigEnabled_AndUserWithoutNoticesAndValidRecoveryCampaigns_responseShouldBeFailure() {
        guard
            let response = setupUseCaseResponse(answerResponse: ConstantsTest.nothingFound,
                                                appconfig: ["campaignsRecoveryPG": "['529', '4']"])
        else { XCTFail("unable to create response"); return }
        XCTAssert(response.isOkResult == false, "Response should be Ok when node is enabled")
    }
    
    func test_execute_withAppConfigEnabled_AndUserWithValidRecoveryCampaignsAllnoticesWithInvalidGroupType_responseShouldBeFailure() {
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.allInvalidGroups,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"])
        else { XCTFail("unable to create response"); return }
        XCTAssert(response.isOkResult == false, "Response should be Failure when all group types are invalid")
    }
    
    func test_execute_withAppConfigDisabled_responseShouldBeFailure() {
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.aviso2_variosProductos,
                                                     appconfig: ["enableRecoveryPG": "false",
                                                                 "campaignsRecoveryPG": "['529', '4']"])
        else { XCTFail("unable to create response"); return }
        XCTAssert(response.isOkResult == false, "Response should be Failure when node is disabled")
    }
    
    func test_execute_withValidNotices_responseShouldHaveCorrectNumberOfItems() {
        let correctDebtCount = 5
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.aviso3_variosProductos,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"]),
            let output = outputFrom(response)
        else { XCTFail("unable to create response"); return }
        XCTAssertTrue(output.debtCount == correctDebtCount, "incorrect number of debt count")
    }
    
    func test_execute_withSomeInvalidAmount_responseShouldHaveCorrectNumberOfItems() {
        let correctDebtCount = 3
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.someInvalidAmount,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"]),
            let output = outputFrom(response)
        else { XCTFail("unable to create response"); return }
        XCTAssertTrue(output.debtCount == correctDebtCount, "incorrect number of debt count")
    }
    
    //MARK- test fetures from confluence
    //https://confluence.alm.europe.cloudcenter.corp/display/MOVPAR/Recobros+-+Nivel+2+y+3+-+Servicios
    
    func test_execute_whenUserHasLevel2And3Notices_ResponseShouldBeLevel3() {
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.noticeLevel2AND3,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"]),
            let output = outputFrom(response)
        else { XCTFail("unable to create response"); return }
        XCTAssert(output.level == 3, "Result level for this user should be 3")
    }
    
    func test_whenPositiveImport_responseShouldIgnoreAccount1805() {
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.aviso2_variosProductos,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"]),
            let output = outputFrom(response)
        else { XCTFail("unable to create response"); return }
        
        let correctAmmount = Float(736.18) //calculated manually from json
        let responseAmmount = Float(output.amount)
        XCTAssert(correctAmmount.isEqual(to: responseAmmount), "invalid ammount")
    }
    
    func test_whenNegativeImport_responseShouldIgnoreAccount1805() {
        guard
            let response = self.setupUseCaseResponse(answerResponse: ConstantsTest.aviso3_variosProductos,
                                                     appconfig: ["campaignsRecoveryPG": "['529', '4']"]),
            let result = outputFrom(response)
        else { XCTFail("unable to create response"); return }
        
        let correctAmmount = Float(3546.76) //calculated manually from json
        let responseAmmount = Float(result.amount)
        XCTAssert(correctAmmount.isEqual(to: responseAmmount), "invalid ammount")
    }
}

private extension GetRecoveryLevelUseCaseTest {
    
    enum ConstantsTest {
        case aviso2_variosProductos
        case aviso3_variosProductos
        case allInvalidGroups
        case noticeLevel2AND3
        case someInvalidAmount
        case nothingFound
    }
    
    func setupUseCaseResponse(answerResponse: ConstantsTest,
                              appconfig: [String: String]? = nil) -> UseCaseResponse<GetRecoveryLevelUseCaseOutput, StringErrorOutput>?   {
        var localconfig: [String: String] = ["enableRecoveryPG": "true"]
        if let config = appconfig {
            for (key, value) in config {
                localconfig[key] = value
            }
        }
        self.mockDataInjector.register(for: \.appConfigLocalData.getAppConfigLocalData, element: AppConfigDTOMock(defaultConfig: localconfig))
        self.mockDataInjector.register(for: \.pullOffers.getCampaigns, filename: "getCampaigns_la")
        
        switch answerResponse {
        case .aviso2_variosProductos:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_level2")
        case .aviso3_variosProductos:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_level3")
        case .allInvalidGroups:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_invalidGroup")
        case .noticeLevel2AND3:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_level2_level3")
        case .someInvalidAmount:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_level2")
        case .nothingFound:
            self.mockDataInjector.register(for: \.recoveryNoticiesData.getRecoveryNoticesMock, filename: "getRecoveryNoticies_empty")
        }
        
        let usecase = GetRecoveryLevelUseCase(dependenciesResolver: self.dependencies)
        return try? usecase.executeUseCase(requestValues: ())
    }
    
     func outputFrom(_ response: UseCaseResponse<GetRecoveryLevelUseCaseOutput, StringErrorOutput>) -> GetRecoveryLevelUseCaseOutput? {
        return try? response.getOkResult()
    }
}
