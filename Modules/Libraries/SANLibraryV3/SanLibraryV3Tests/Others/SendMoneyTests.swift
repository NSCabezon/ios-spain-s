import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class SendMoneyTests: BaseLibraryTests {
    
    override func setUp() {
                setLoginUser(newLoginUser: LOGIN_USER.LOANS_LOGIN)
                resetDataRepository()
                super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testLoadCMPSStatus(){
//        
//        let rawString = "SL9rXEpMGNUxbtcLNhs3qQ=="
//        let clave = "004900013390335181RMLF9106883000"
//        //RESULTADO: 685796586
//        
//        guard let inputBase64 = rawString.data(using: .utf8)?.base64EncodedString() else {
//            return
//        }
//        
//        do {
//            let decrypted = try DataCipher.decryptDESde(rawString, clave)
//            print(decrypted)
//            let encrypted = try DataCipher.encryptDESde(decrypted, clave)
//            print("encrypted : \(encrypted)")
//            print("raw : \(rawString)")
//        } catch let e {
//            print("FAILURE: \(e.localizedDescription)")
//        }
        
                do{
        
                    let loadCMPSStatusResponse = try bsanSendMoneyManager?.loadCMPSStatus()
        
                    guard let loadCMPSStatusResponseStrong = loadCMPSStatusResponse else {
                        logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                        return
                    }
        
                    guard let loadCMPSStatus = try getResponseData(response: loadCMPSStatusResponseStrong) else {
                        logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                        return
                    }
        
                    logTestSuccess(result: loadCMPSStatus, function: #function)
        
                } catch let error{
                    logTestException(error: error, function: #function)
                }
    }
    
    
}
