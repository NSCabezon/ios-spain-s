import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class ModifyPeriodicTransferTest: BaseLibraryTests {
    typealias T = TransferDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.erradi)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testModifyScheduledTransferDetailWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 8, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let getScheduledTransfersResponse = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: nil)
            guard var transfersResponse = try getResponseData(response: getScheduledTransfersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - loadScheduledTransfers", function: #function)
                return
            }
            
            let transferScheduled = transfersResponse.transactionDTOs[1]
            
            let getDetailScheduledTransferInput = try bsanTransfersManager!.getScheduledTransferDetail(account: account, transferScheduledDTO: transferScheduled)
            guard let transfersDetailResponse = try getResponseData(response: getDetailScheduledTransferInput) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - getScheduledTransferDetail", function: #function)
                return
            }
            
            
            let getModifyScheduledTransfer = try bsanTransfersManager!.modifyPeriodicTransferDetail(originAccountDTO: account, transferScheduledDTO: transferScheduled, transferScheduledDetailDTO: transfersDetailResponse)
            guard let modifyScheduledTransfer = try getResponseData(response: getModifyScheduledTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - modifyPeriodicTransferDetail", function: #function)
                return
            }
            
            logTestSuccess(result: modifyScheduledTransfer, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateModifyDeferredTransferWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 8, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            let modifyScheduledTransferInput = TestUtils.getModifyScheduledTransferInputData()
            
            let getScheduledTransfersResponse = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: nil)
            guard var transfersResponse = try getResponseData(response: getScheduledTransfersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - loadScheduledTransfers", function: #function)
                return
            }
            
            let transferScheduled = transfersResponse.transactionDTOs[1]
            
            let getDetailScheduledTransferInput = try bsanTransfersManager!.getScheduledTransferDetail(account: account, transferScheduledDTO: transferScheduled)
            guard let transfersDetailResponse = try getResponseData(response: getDetailScheduledTransferInput) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - getScheduledTransferDetail", function: #function)
                return
            }
            
            
            let getModifyScheduledTransfer = try bsanTransfersManager!.modifyPeriodicTransferDetail(originAccountDTO: account, transferScheduledDTO: transferScheduled, transferScheduledDetailDTO: transfersDetailResponse)
            guard var modifyScheduledTransfer = try getResponseData(response: getModifyScheduledTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - modifyDeferredTransferDetail", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &modifyScheduledTransfer.signatureDTO)
            
            let validateModifyDeferredTransfer = try bsanTransfersManager!.validateModifyPeriodicTransfer(originAccountDTO: account, modifyScheduledTransferInput: modifyScheduledTransferInput, modifyPeriodicTransferDTO: modifyScheduledTransfer, transferScheduledDetailDTO: transfersDetailResponse)
            guard let validateModifyDeferred = try getResponseData(response: validateModifyDeferredTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - validateModifyDeferredTransfer", function: #function)
                return
            }
            
            logTestSuccess(result: validateModifyDeferred, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}



