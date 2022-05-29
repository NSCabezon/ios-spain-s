//

import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class FavouriteTransferTest: BaseLibraryTests {

    override func setUp() {
        environmentDTO = BSANEnvironments.environmentPre
        setLoginUser(newLoginUser: LOGIN_USER.eva)
        resetDataRepository()
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFavouriteTransferList() {
        do {
            let response = try bsanFavouriteTransfersManager?.getFavouriteTransfers()
            guard let responseData = try response?.getResponseData() else {
                return XCTFail()
            }
            XCTAssert(responseData.count > 0, "Service looks good, but its weird that zero movements found, hmmm!")
        } catch {
            logTestException(error: error, function: #function)
        }
    }
}
