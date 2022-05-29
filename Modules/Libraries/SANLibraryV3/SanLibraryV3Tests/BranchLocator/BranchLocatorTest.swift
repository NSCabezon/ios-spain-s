//
import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class BranchLocatorTest: BaseLibraryTests {

    override func setUp() {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.CARD_MAP_TRANSACTIONS)
        resetDataRepository()
        super.setUp()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetNearAtmsTest() {
        do {
            // -----   getNearATMs  ---
            let input = BranchLocatorATMParameters(lat: 40.425168, lon: -3.68463, customer: false, country: .es)
            guard let branchLocatorRequest = try bsanBranchLocatorManager?.getNearATMs(input) else {
                return
            }
            guard branchLocatorRequest.isSuccess(), let response = try branchLocatorRequest.getResponseData() else {
                XCTFail("Branch locator globile failed" )
                return
            }
            XCTAssertNotNil(response)
            
            // -----   Enriched getNearATMs  ---
            guard let enrichedRequest = try bsanBranchLocatorManager?.getEnrichedATM(BranchLocatorEnrichedATMParameters(branches: response)) else {
                return
            }
            guard enrichedRequest.isSuccess(), let enrichedResponse = try enrichedRequest.getResponseData() else {
                XCTFail("Branch locator SANTANDER failed" )
                return
            }
            XCTAssertNotNil(enrichedResponse)
            XCTAssert(enrichedResponse.count >= 77, "Not enough data to continue test")
            let firstEntity = enrichedResponse[77]
            XCTAssertEqual(firstEntity.dispensation, true)
            XCTAssertEqual(firstEntity.caj10, true)
            XCTAssertEqual(firstEntity.caj20, true)
            XCTAssertEqual(firstEntity.caj50, false)
            XCTAssertEqual(firstEntity.contactless, false)
        } catch {
            XCTFail("Branch locator SANTANDER failed \(error.localizedDescription)")
        }
    }
}


