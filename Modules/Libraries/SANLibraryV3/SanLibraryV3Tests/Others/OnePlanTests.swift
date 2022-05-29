import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class OnePlanTests: BaseLibraryTests {
    
    override func setUp() {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.ONE_PLAN)
        resetDataRepository()
        super.setUp()
    }
    
    func testCheckOnePlan() {
        do {
            let response = try bsanOnePlanManager!.checkOnePlan(ranges: [ProductOneRangeDTO(type: 788, subtypeFrom: 3, subtypeTo: 3)])
            XCTAssertTrue(response.isSuccess(), "The response wasn't successful.")
            
            guard response.isSuccess() else {
                XCTFail("The response wasn't successful.")
                return
            }
            
            XCTAssertNotNil(try getResponseData(response: response), "The response data is empty.")
            
            guard let dto = try getResponseData(response: response) else {
                XCTFail("The response data is empty.")
                return
            }
            
            logTestSuccess(result: dto, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
