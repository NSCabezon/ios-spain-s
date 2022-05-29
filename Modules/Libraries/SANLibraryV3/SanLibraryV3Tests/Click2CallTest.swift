//

import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class Click2CallTest: BaseLibraryTests {
    
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClick2Call() {
        do {
            let responseData = try bsanManagersManager?.loadClick2Call("Bloqueo de tarjeta")
            if ((try responseData?.getResponseData()) != nil) {
                XCTAssert((responseData != nil))
            } else {
                XCTFail()
            }
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testClick2CallNoReason() {
        do {
            let responseData = try bsanManagersManager?.loadClick2Call("")
            if (try responseData?.getResponseData()) != nil {
                XCTAssert((responseData != nil))
            } else {
                XCTFail()
            }
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testClick2CallNilReason() {
        do {
            let responseData = try bsanManagersManager?.loadClick2Call(nil)
            if (try responseData?.getResponseData()) != nil {
                XCTAssert((responseData != nil))
            } else {
                XCTFail()
            }
        } catch {
            logTestException(error: error, function: #function)
        }
    }
}
