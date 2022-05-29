import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

final class RecoveryNoticesTest: BaseLibraryTests {
    private func login(withUser user: LOGIN_USER) {
        setLoginUser(newLoginUser: user)
        login(isPb: isPb)
    }
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.raul)
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
        resetDataRepository()
    }
    
    func testRecoveryNotices_WhenCallingGetRecoveryNotices_TheResponseShouldBeSuccessful() {
        do {
            guard let bsanRecoveryNoticesManager = bsanRecoveryNoticesManager else {
                XCTFail("The recovery notices manager is nil.")
                return
            }
            let response = try bsanRecoveryNoticesManager.getRecoveryNotices()
            XCTAssertTrue(response.isSuccess(), "The response wasn't successful.")
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testRecoveryNotices_WhenCallingGetRecoveryNotices_TheResponseDataDTOShouldNotBeNil() {
        do {
            guard let bsanRecoveryNoticesManager = bsanRecoveryNoticesManager else {
                XCTFail("The recovery notices manager is nil.")
                return
            }
            let response = try bsanRecoveryNoticesManager.getRecoveryNotices()
            XCTAssertNotNil(try response.getResponseData())
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
        }
    }
    
    func testRecoveryNotices_WhenCallingGetRecoveryNotices_ShouldHaveSecondLevel() {
        do {
            guard let bsanRecoveryNoticesManager = bsanRecoveryNoticesManager else {
                XCTFail("The recovery notices manager is nil.")
                return
            }
            let response = try bsanRecoveryNoticesManager.getRecoveryNotices()
            guard let responseData = try response.getResponseData() else {
                XCTFail("The response data is nil.")
                return
            }
            XCTAssert(responseData.contains(where: { $0.noticeLevel == 2 }))
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
        }
    }
    
    func testRecoveryNotices_WhenCallingGetRecoveryNotices_ShouldHaveThirdLevel() {
        resetDataRepository()
        login(withUser: LOGIN_USER.DEPOSITS_LOGIN)
        do {
            guard let bsanRecoveryNoticesManager = bsanRecoveryNoticesManager else {
                XCTFail("The recovery notices manager is nil.")
                return
            }
            let response = try bsanRecoveryNoticesManager.getRecoveryNotices()
            guard let responseData = try response.getResponseData() else {
                XCTFail("The response data is nil.")
                return
            }
            XCTAssert(responseData.contains(where: { $0.noticeLevel == 3 }))
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
        }
    }
}
