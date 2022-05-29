import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class AuthTests: BaseLibraryTests {
    
    func testRefreshToken(){
        
        do {
            
            guard let dataProvider = try bsanDataProvider else {
                logTestError(errorMessage: "bsanDataProvider NIL", function: #function)
                return
            }
            
            let credential = try bsanDataProvider!.getAuthCredentials().soapTokenCredential
            
            let _ = try bsanAuthManager!.refreshToken()
            
            let newCredential = try bsanDataProvider!.getAuthCredentials().soapTokenCredential
            
            if newCredential == ""{
                logTestError(errorMessage: "NUEVO TOKEN VACIO", function: #function)
                return
            }
            
            XCTAssert(credential != newCredential)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
