import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class AccountTests: BaseLibraryTests {
    typealias T = AccountDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testGetAccountTransactions() {
        
        do {
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let accountTransactionsResponse = try bsanAccountManager!.getAccountTransactions(forAccount: account, pagination: nil, dateFilter: nil)
            
            guard let accountTransactionsDTO = try getResponseData(response: accountTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: accountTransactionsDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetAccountTransactionsWithPagination() {
        
        do {
            
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let accountTransactionsResponse = try bsanAccountManager!.getAccountTransactions(forAccount: account, pagination: nil, dateFilter: nil)
            
            guard let accountTransactionsDTO = try getResponseData(response: accountTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            print("\n\n\(#function) :\n\(accountTransactionsDTO)")
            
            if !accountTransactionsDTO.pagination.endList{
                print("\(#function) SecondPage")
                
                let accountTransactionsResponseSecond = try bsanAccountManager!.getAccountTransactions(forAccount: account, pagination: accountTransactionsDTO.pagination, dateFilter: nil)
                
                guard let accountTransactionsDTOSecond = try getResponseData(response: accountTransactionsResponseSecond) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
            
                logTestSuccess(result: accountTransactionsDTOSecond, function: #function)

            }
            else{
                logTestError(errorMessage: "getAccountTransactions ONLY HAS ONE PAGE", function: #function)
            }
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetAccountDetail() {
        
        do {
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let accountDetailResponse = try bsanAccountManager!.getAccountDetail(forAccount: account)
            
            guard let accountDetailDTO = try getResponseData(response: accountDetailResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: accountDetailDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetAccountTransactionDetail() {
        
        do {
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let accountTransactionsResponse = try bsanAccountManager!.getAccountTransactions(forAccount: account, pagination: nil, dateFilter: nil)
            
            guard let accountTransactionsDTO = try getResponseData(response: accountTransactionsResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let accountTransactionDTO = accountTransactionsDTO.transactionDTOs.first else {
                logTestError(errorMessage: "RETURNED NO accountTransactionDTO", function: #function)
                return
            }
            
            let accountTransactionDetailResponse = try bsanAccountManager!.getAccountTransactionDetail(from: accountTransactionDTO)
            
            guard let accountTransactionDetailDTO = try getResponseData(response: accountTransactionDetailResponse) else{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: accountTransactionDetailDTO, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetAccountEasyPay() {
        do {
            let response = try bsanAccountManager!.getAccountEasyPay()
            logTestSuccess(result: try response.getResponseData(), function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testChangeAccountAlias() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let changeAccountAliasResponse = try bsanAccountManager!.changeAccountAlias(accountDTO: account, newAlias: FieldsUtils.ACCOUNT_NEW_ALIAS)

            XCTAssert(changeAccountAliasResponse.isSuccess())
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testAccountFutureBillList() {
        do {
            let url = "https://gatewayweb-san-recibos-prox-vencimiento-test-pre.appls.san01.san.pre.bo1.paas.cloudcenter.corp/recibos"
            let params = AccountFutureBillParams(iban: "004900753000580956", status: "AUT", numberOfElements: 3, page: 0)
            let response = try bsanAccountManager!.getAccountFutureBills(params: params)
            XCTAssert(response.isSuccess())
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
