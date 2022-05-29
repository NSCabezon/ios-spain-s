import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

final class AviosTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.AVIOS)
        resetDataRepository()
        super.setUp()
    }
    
    func testAvios_WhenCallingAviosInfoService_TheResponseShouldBeSuccessful() {
        do {
            guard let bsanAviosManager = bsanAviosManager else {
                XCTFail("The avios manager is nil.")
                return
            }
            let response = try bsanAviosManager.getAviosDetail()
            XCTAssertTrue(response.isSuccess(), "The response wasn't successful.")
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testAvios_WhenCallingAviosInfoService_TheResponseDataDTOShouldNotBeNil() {
        do {
            guard let bsanAviosManager = bsanAviosManager else {
                XCTFail("The avios manager is nil.")
                return
            }
            let response = try bsanAviosManager.getAviosDetail()
            XCTAssertNotNil(try response.getResponseData())
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
        }
    }
    
    func testAvios_WhenCallingAviosInfoService_TheResponseDataDTOShouldBeSaved() {
        do {
            guard let bsanAviosManager = bsanAviosManager else {
                XCTFail("The avios manager is nil.")
                return
            }
            _ = try bsanAviosManager.getAviosDetail()
            XCTAssertNotNil(try bsanDataProvider?.get(\.aviosDetail))
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
        }
    }
}
