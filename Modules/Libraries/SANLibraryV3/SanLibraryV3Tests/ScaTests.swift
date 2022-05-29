import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class ScaTests: BaseLibraryTests {
//TODO: hacer los tests.
    override func setUp() {
        environmentDTO = BSANEnvironments.environmentCiber
        setLoginUser(newLoginUser: LOGIN_USER.SCA)
        resetDataRepository()
        super.setUp()
    }
    
    func testRequestDevice() {
        do {
            let response: BSANResponse<CheckScaDTO> = try bsanScaManager!.checkSca()
            let responseData: CheckScaDTO? = try response.getResponseData()
            guard responseData != nil else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: responseData, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
}
