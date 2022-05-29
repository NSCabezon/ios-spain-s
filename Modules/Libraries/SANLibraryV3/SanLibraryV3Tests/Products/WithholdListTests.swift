import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class WithholdListTests: BaseLibraryTests {
    
    override func setUp() {
        //        isPb = true
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.WITHHOLDING_LIST)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testWithholdList() {
        let url = "https://gatewayweb-san-recibos-prox-vencimiento-test-pre.appls.san01.san.pre.bo1.paas.cloudcenter.corp/api/v1/envioPagos/retenciones"
        // ES9400490075412816836261
        do{
            let withholdList = try bsanAccountManager?.getWithholdingList( iban: "ES8300490075492916738889", currency: "EUR")
            if withholdList == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let withholdListDTO = try getResponseData(response: withholdList!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: withholdListDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}
