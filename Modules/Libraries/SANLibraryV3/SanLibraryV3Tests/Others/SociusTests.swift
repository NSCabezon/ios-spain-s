import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class SociusTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.SIGNATURE_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    func testLoadSociusDetailAccountsAll(){
        
        do{
            
            let loadSociusDetailAccountsAllResponse = try bsanSociusManager!.loadSociusDetailAccountsAll()
            
            guard let loadSociusDetailAccountsAll = try getResponseData(response: loadSociusDetailAccountsAllResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loadSociusDetailAccountsAll, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
