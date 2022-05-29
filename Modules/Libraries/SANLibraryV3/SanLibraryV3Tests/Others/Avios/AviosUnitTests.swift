import XCTest
@testable import SanLibraryV3
import CoreFoundationLib

final class AviosUnitTests: XCTestCase {
    private var bsanDataProvider: BSANDataProvider!
    private var sanRestServicesMock: SanRestServicesMock!
    private var bsanAviosManager: BSANAviosManager!

    override func setUp() {
        super.setUp()
        let dataRepository = DataRepositoryMock()
        let appInfo = VersionInfoDTO(bundleIdentifier: "bundleIdentifier", versionName: "versionName")
        bsanDataProvider = BSANDataProvider(dataRepository: dataRepository, appInfo: appInfo)
        sanRestServicesMock = SanRestServicesMock()
        bsanAviosManager = BSANAviosManagerImplementation(bsanDataProvider: bsanDataProvider,
                                                          sanRestServices: sanRestServicesMock)
    }
    
    override func tearDown() {
        super.tearDown()
        sanRestServicesMock = nil
        bsanAviosManager = nil
    }
    
    func testAvios_WhenCallingAviosDetailServiceWithOkResponse_TheResponseShouldBeSuccessful() {
        //Prepare
        let responseFile = "GetAviosInfoSuccessResponse"
        sanRestServicesMock.configure(withFileName: responseFile)
        
        //Test
        let response: BSANResponse<AviosDetailDTO>
        do {
            response = try bsanAviosManager.getAviosDetail()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }
        
        //Consult
        XCTAssertTrue(response.isSuccess(), "The response wasn't successful.")
    }
    
    func testAvios_WhenCallingAviosDetailService_AndReturnedEmptyResponse_TheResponseShouldNotBeSuccessful() {
        //Prepare
        let responseFile = "EmptyResponse"
        sanRestServicesMock.configure(withFileName: responseFile)

        //Test
        let response: BSANResponse<AviosDetailDTO>
        do {
            response = try bsanAviosManager.getAviosDetail()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }
        
        //Consult
        XCTAssertTrue(!response.isSuccess(), "The response wasn't successful.")
    }
    
    func testAvios_WhenCallingAviosDetailServiceWithOkResponse_TheResponseDataDTOShouldNotBeNil() {
        //Prepare
        let responseFile = "GetAviosInfoSuccessResponse"
        sanRestServicesMock.configure(withFileName: responseFile)

        //Test
        let response: BSANResponse<AviosDetailDTO>
        do {
            response = try bsanAviosManager.getAviosDetail()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }
        
        //Consult
        XCTAssertNotNil(try response.getResponseData())
    }
    
    func testAvios_WhenCallingAviosDetailService_TheResponseDataDTOShouldBeSaved() {
        //Prepare
        let responseFile = "GetAviosInfoSuccessResponse"
        sanRestServicesMock.configure(withFileName: responseFile)

        //Test
        do {
            _ = try bsanAviosManager.getAviosDetail()
        } catch let error {
            XCTFail("Something went wrong, raised error \(error)")
            return
        }
        
        //Consult
        XCTAssertNotNil(try bsanDataProvider.get(\.aviosDetail))
    }
}
