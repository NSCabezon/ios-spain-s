import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class ManagersTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.ACCOUNTS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    func testLoadManagers(){
        
        do{
            
            let _ = try bsanManagersManager!.loadManagers()
            
            let getManagersResponse = try bsanManagersManager!.getManagers()

            guard let getManagers = try getResponseData(response: getManagersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: getManagers, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
