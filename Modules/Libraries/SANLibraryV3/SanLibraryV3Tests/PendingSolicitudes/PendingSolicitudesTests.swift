//

import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PendingSolicitudesTests: BaseLibraryTests {
    typealias T = PendingSolicitudeListDTO
    
    override func setUp() {
        self.setLoginUser(newLoginUser: LOGIN_USER.PENDING_SOLICITUDE)
        self.resetDataRepository()
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPendingSolicitudesWS() {
        do {
            
            let response = try bsanPendingSolicitudesManager!.getPendingSolicitudes()
            
            guard let localResponse = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard localResponse != nil else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            localResponse.solicitudesDTOs?.forEach {
                logTestSuccess(result: $0, function: #function)
            }
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
