import XCTest
@testable import SanLibraryV3
import CoreFoundationLib

final class RecoveryNoticesUnitTest: XCTestCase {
    private var bsanDataProvider: BSANDataProvider!
    private var sanRestServicesMock: SanRestServicesMock!
    private var bsanRecoveryNoticesManager: BSANRecoveryNoticesManager!

    override func setUp() {
        super.setUp()
        let dataRepository = DataRepositoryMock()
        let appInfo = VersionInfoDTO(bundleIdentifier: "bundleIdentifier", versionName: "versionName")
        bsanDataProvider = BSANDataProvider(dataRepository: dataRepository, appInfo: appInfo)
        sanRestServicesMock = SanRestServicesMock()
        bsanRecoveryNoticesManager = BSANRecoveryNoticesManagerImplementation(bsanDataProvider: bsanDataProvider,
                                                                              sanRestServices: sanRestServicesMock)
    }
    
    override func tearDown() {
        super.tearDown()
        sanRestServicesMock = nil
        bsanRecoveryNoticesManager = nil
    }
    
    func testRecoveryNotices_WhenCallingRecoveryNoticesServiceWithOkResponse_TheResponseShouldBeSuccessful() {
        //Prepare
        let responseFile = "RecoveryNoticesSecondLevelResponse"
        sanRestServicesMock.configure(withFileName: responseFile)
        
        //Test
        let response: BSANResponse<[RecoveryDTO]>
        do {
            response = try bsanRecoveryNoticesManager.getRecoveryNotices()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }
        
        //Consult
        XCTAssert(response.isSuccess(), "The response wasn't successful.")
    }
    
    func testRecoveryNotices_WhenCallingRecoveryNoticesService_AndReturnedEmptyResponse_TheResponseShouldNotBeSuccessful() {
        //Prepare
        let responseFile = ""
        sanRestServicesMock.configure(withFileName: responseFile)

        //Test
        let response: BSANResponse<[RecoveryDTO]>
        do {
            response = try bsanRecoveryNoticesManager.getRecoveryNotices()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }

        //Consult
        XCTAssertFalse(response.isSuccess(), "The response wasn't successful.")
    }
    
    func testRecoveryNotices_WhenCallingRecoveryNoticesServiceWithOkResponse_TheResponseDataDTOShouldNotBeNil() {
        //Prepare
        let responseFile = "RecoveryNoticesSecondLevelResponse"
        sanRestServicesMock.configure(withFileName: responseFile)

        //Test
        let response: BSANResponse<[RecoveryDTO]>
        do {
            response = try bsanRecoveryNoticesManager.getRecoveryNotices()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }

        //Consult
        XCTAssertNotNil(try response.getResponseData())
    }
}
