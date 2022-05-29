import CoreFoundationLib
import XCTest
@testable import SanLibraryV3

class BSANSignBasicOperationTests: BaseLibraryTests {
    
    override func setUpWithError() throws {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.SUBSCRIPTIONS_M4M)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func test_service_getSingPattern_shouldBeSuccess() {
        guard let response = try? bsanSignBasicOperationManager?.getSignaturePattern() else {
            return  XCTFail("Fail to load get sign pattern")
        }
        XCTAssertTrue(response.isSuccess(), "Response doesn't have data")
    }
    
    func test_service_startSignPattern01_shouldBeSuccess() {
        guard let response = try? bsanSignBasicOperationManager?.startSignPattern("SIGN01", instaID: "pruebaHistoricoMensualSpotify001" ) else {
            return XCTFail("Fail to load get sign pattern")
        }
        XCTAssertTrue(response.isSuccess())
    }
    
    func test_service_getPositions_SIGN01_shouldBeSuccess() {
        guard let signPatternResponse = try? bsanSignBasicOperationManager?.startSignPattern("SIGN01", instaID: "pruebaHistoricoMensualSpotify001" ),
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
    
    func test_service_validateSign_shouldBeSuccess() {
        guard let signPatternResponse = try? bsanSignBasicOperationManager?.startSignPattern("SIGN01", instaID: "pruebaHistoricoMensualSpotify001" ),
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
                                        otpData: nil)) else {
            return XCTFail("Fail to load get sign positions")
        }
        XCTAssertTrue(validateSignResponse.isSuccess())
    }
}
