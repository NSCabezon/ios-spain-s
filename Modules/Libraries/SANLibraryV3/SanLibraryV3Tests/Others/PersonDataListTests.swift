import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class PersonDataListTests: BaseLibraryTests {
    
    override func setUp() {
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.ACCOUNTS_LOGIN)
        resetDataRepository()
        super.setUp()
    }
    
    private func checkProductSubtype(accountDTO: AccountDTO, productType: String, productSubtype: String) -> Bool{
        return accountDTO.productSubtypeDTO != nil
            && productType == accountDTO.productSubtypeDTO?.productType
            && productSubtype == accountDTO.productSubtypeDTO?.productSubtype
    }
    
    func testLoadPersonDataList(){
        
        do{
            
            setUp(loginUser: LOGIN_USER.iñaki, pbToSet: nil)
            
            guard let accountsResponse = try bsanAccountManager?.getAllAccounts() else{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let accounts = try getResponseData(response: accountsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let clients = accounts.filter({checkProductSubtype(accountDTO: $0, productType: "300", productSubtype: "325")
                                                || checkProductSubtype(accountDTO: $0, productType: "302", productSubtype: "549")})
                                    .map({$0.client})
                                    .compactMap({$0})
            
            if clients.count == 0{
                logTestError(errorMessage: "NO CLIENTS WITH THE PROPER PRODUCT SUBTYPE", function: #function)
                return
            }
            
            let loadPersonDataListResponse = try bsanPersonDataManager!.loadPersonDataList(clientDTOs: clients)
            
            guard let loadPersonDataList = try getResponseData(response: loadPersonDataListResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: loadPersonDataList, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testLoadBasicPersonData() {
        
        do {
            
            guard let personDataResponse = try bsanPersonDataManager?.loadBasicPersonData() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let personBasicData = try getResponseData(response: personDataResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: personBasicData, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
