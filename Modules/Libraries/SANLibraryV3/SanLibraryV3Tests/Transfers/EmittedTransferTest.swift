import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class EmittedTransferTest: BaseLibraryTests {
    typealias T = TransferDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testValidateGetEmittedTransferWS(){
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 3, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            let contract = account.contract?.contratoPK
            let dateFrom = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            let dateTo = Date()
            
            let dateFilter = DateFilter(from: dateFrom, to: dateTo)
            let getEmittedTransfersResponse = try bsanTransfersManager!.loadEmittedTransfers(account: account, amountFrom: nil, amountTo: nil, dateFilter: dateFilter, pagination: nil)
            guard var transfersResponse = try getResponseData(response: getEmittedTransfersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            while !transfersResponse.paginationDTO.endList {
                let getEmittedTransfersResponseLocal = try bsanTransfersManager!.loadEmittedTransfers(account: account, amountFrom: nil, amountTo: nil, dateFilter: dateFilter, pagination: transfersResponse.paginationDTO)
                guard let transfersResponseLocal = try getResponseData(response: getEmittedTransfersResponseLocal) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                transfersResponse = transfersResponseLocal
                getSessionData()?.transferInfo.addTransferEmitted(transferEmittedListDTO: transfersResponse, contract: contract ?? "")
            }
            
            logTestSuccess(result: transfersResponse, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateGetEmittedDetailTransferWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            let dateFrom = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            let dateTo = Date()
            
            let dateFilter = DateFilter(from: dateFrom, to: dateTo)
            let getEmittedTransfersResponse = try bsanTransfersManager!.loadEmittedTransfers(account: account, amountFrom: nil, amountTo: nil, dateFilter: dateFilter, pagination: nil)
            
            if let emittedTransfer = try getEmittedTransfersResponse.getResponseData()?.transactionDTOs[1] {
                let getEmittedTransferDetaiResponse = try bsanTransfersManager!.getEmittedTransferDetail(transferEmittedDTO: emittedTransfer)
                
                logTestSuccess(result: getEmittedTransferDetaiResponse, function: #function)
                return
            }            
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateGetEmittedDetailNoSepaTransferWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 3, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            let dateFrom = Calendar.current.date(byAdding: .month, value: -1, to: Date())
            let dateTo = Date()
            
            let dateFilter = DateFilter(from: dateFrom, to: dateTo)
            let getEmittedTransfersResponse = try bsanTransfersManager!.loadEmittedTransfers(account: account, amountFrom: nil, amountTo: nil, dateFilter: dateFilter, pagination: nil)
            
            if let emittedTransfer = try getEmittedTransfersResponse.getResponseData()?.transactionDTOs[1] {
                let getEmittedTransferDetaiResponse = try bsanTransfersManager!.loadEmittedNoSepaTransferDetail(transferEmittedDTO: emittedTransfer)
                
                logTestSuccess(result: getEmittedTransferDetaiResponse, function: #function)
                return
            }
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}

