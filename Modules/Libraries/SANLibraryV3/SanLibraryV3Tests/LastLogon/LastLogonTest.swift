import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class LastLogonTest: BaseLibraryTests {
    
    typealias T = LastLogonDTO
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.LAST_LOGON)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetLastLogonInfo() {
        do {
            let response = try bsanLastLogonManager?.getLastLogonInfo()
            if let responseData = try response?.getResponseData() {
                let isThereLastLogonDate = !(responseData.lastLogonDate?.isEmpty ?? false)
                let isThereLastFailedLogonDate = !(responseData.lastFailedLogonDate?.isEmpty ?? false)
                let okCondition = isThereLastFailedLogonDate || isThereLastLogonDate
                XCTAssert(okCondition, "Service has last logonInfo")
            } else {
                XCTFail()
            }
        } catch {
            logTestException(error: error, function: #function)
        }
    }
}
