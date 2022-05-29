import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

final class AviosTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.AVIOS)
        self.isPb = true
        resetDataRepository()
        super.setUp()
    }
    
    func testGetAviosInfo() {
        do {
            XCTAssertNotNil(bsanAviosManager, "The avios manager is nil.")
            guard let bsanAviosManager = bsanAviosManager else {
                XCTFail("The avios manager is nil.")
                return
            }
            let response = try bsanAviosManager.getAviosInfo()
            XCTAssertTrue(response.isSuccess(), "The response wasn't successful.")
            guard response.isSuccess() else {
                XCTFail("The response wasn't successful.")
                return
            }
            XCTAssertNotNil(try getResponseData(response: response), "The response data is nil.")
            guard let info = try response.getResponseData() else {
                logTestError(errorMessage: "The response data is nil.", function: #function)
                return
            }
            logTestSuccess(result: info, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
