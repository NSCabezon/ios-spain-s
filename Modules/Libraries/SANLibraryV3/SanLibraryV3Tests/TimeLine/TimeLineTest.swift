//

import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class TimeLineTest: BaseLibraryTests {

    typealias T = TimeLineMovementDTO
    
    var getTimeLineSessionData = false
    
    override func setUp() {
        //setLoginUser(newLoginUser: LOGIN_USER.TIMELINE)
        environmentDTO = BSANEnvironments.environmentPro
        resetDataRepository()
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTimeLineMovements() {
        do {
            let queryDate = DateFormats.safeDate("2019-10-31", format: .YYYYMMDD)
            let parameters = TimeLineMovementsParameters(date: queryDate!, limit: 50, direction: TimeLineDirection.forward)
            let response = try bsanTimelineManager?.getMovements(parameters)
            if let responseData = try response?.getResponseData() {
                XCTAssert(responseData.data.movements.count > 0, "Service looks good, but its weird that zero movements found, hmmm!")
            } else {
                XCTFail()
            }
            
        } catch {
            logTestException(error: error, function: #function)
        }
    }

}
