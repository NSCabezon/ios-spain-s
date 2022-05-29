//
//  BSANSignBasicOperationWithOTPTests.swift
//  SanLibraryV3Tests
//
//  Created by Rubén Márquez Fernández on 13/5/21.
//  Copyright © 2021 com.ciber. All rights reserved.
//

import CoreFoundationLib
import XCTest
@testable import SanLibraryV3

class BSANSignBasicOperationWithOTPTests: BaseLibraryTests {
    
    override func setUpWithError() throws {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.BIZUM_HISTORIC)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func test_service_startSignPattern02_shouldBeSuccess() {
        guard let response = try? bsanSignBasicOperationManager?.startSignPattern("SIGN02", instaID: "pruebaHistoricoMensualSpotify001" ) else {
            return XCTFail("Fail to load get sign pattern")
        }
        XCTAssertTrue(response.isSuccess())
    }
    
    func test_service_getPositions_SIGN02_shouldBeSuccess() {
        guard let signPatternResponse = try? bsanSignBasicOperationManager?.startSignPattern("SIGN02", instaID: "instaprueba1234567Amazon04" ),
              let data = try? signPatternResponse.getResponseData() else {
            return XCTFail("Fail to load get sign pattern")
        }
        guard let signPositionsResponse = try? bsanSignBasicOperationManager?
                .validateSignPattern(SignValidationInputParams(
                                        token: data.token,
                                        signatureData: nil,
                                        otpData: nil)) else {
            return XCTFail("Fail to load get sign positions")
        }
        XCTAssertTrue(signPositionsResponse.isSuccess())
    }
    
    func test_service_validateSignOTP_shouldBeSuccess() {
        guard let signPatternResponse = try? bsanSignBasicOperationManager?.startSignPattern("SIGN02", instaID: "instaprueba1234567Amazon04" ),
              let data = try? signPatternResponse.getResponseData() else {
            return XCTFail("Fail to load get sign pattern")
        }
        
        guard let signPositionsResponse = try? bsanSignBasicOperationManager?
                .validateSignPattern(SignValidationInputParams(
                                        token: data.token,
                                        signatureData: nil,
                                        otpData: nil)),
              let signPositionsData = try? signPositionsResponse.getResponseData() else {
            return XCTFail("Fail to load get sign positions")
        }
        
        guard let validateSignResponse = try? bsanSignBasicOperationManager?
                .validateSignPattern(SignValidationInputParams(
                                        token: signPositionsData.token,
                                        signatureData: SignatureDataInputParams(
                                            positions: signPositionsData.signatureData?.positions ?? "",
                                            positionsValues: "2 2 2 2"),
                                        otpData: self.getOtpDataInputParams())) else {
            return XCTFail("Fail to load get sign positions")
        }
        XCTAssertTrue(validateSignResponse.isSuccess())
    }
}

private extension BSANSignBasicOperationWithOTPTests {
    func getOtpDataInputParams() -> OtpDataInputParams {
        return OtpDataInputParams(
            xmlOperative: "<xml><![CDATA[<?xml version=\"1.0\" encoding=\"UTF-8\"?><SUSCTJM4M><codigoMulidi>00000054</codigoMulidi></SUSCTJM4M>]]></xml>",
            codeOTP: "",
            ticketOTP: "",
            company: "0000",
            language: "es_ES",
            channel: "RML",
            contract: "004969023390354755")
    }
}
