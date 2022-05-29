//
//  ScheduledTransferTest.swift
//  SanLibraryV3Tests
//
//  Created by Carlos Panizo on 31/10/2018.
//  Copyright © 2018 com.ciber. All rights reserved.
//
import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class ScheduledTransferTest: BaseLibraryTests {
    typealias T = TransferDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testValidateGetScheduledransferWS(){
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            let contract = account.contract?.contratoPK
            
            let getScheduledTransfersResponse = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: nil)
            guard var transfersResponse = try getResponseData(response: getScheduledTransfersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            while !transfersResponse.paginationDTO.endList {
                let getScheduledTransfersResponseLocal = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: transfersResponse.paginationDTO)
                guard let transfersResponseLocal = try getResponseData(response: getScheduledTransfersResponseLocal) else {
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                transfersResponse = transfersResponseLocal
                getSessionData()?.transferInfo.addTransferScheduled(transferScheduledListDTO: transfersResponse, contract: contract ?? "")
            }
            
            logTestSuccess(result: transfersResponse, function: #function)
            
        } catch let error{
             logTestException(error: error, function: #function)
        }
    }
    
    func testValidateGetScheduledDetailTransferWS(){
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let getScheduledTransfersResponse = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: nil)

            if let scheduledTransfer = try getScheduledTransfersResponse.getResponseData()?.transactionDTOs[1] {
                let getScheduledTransferDetaiResponse = try bsanTransfersManager!.getScheduledTransferDetail(account: account, transferScheduledDTO: scheduledTransfer)
                if getScheduledTransferDetaiResponse.isSuccess() {
                    logTestSuccess(result: getScheduledTransferDetaiResponse, function: #function)
                    return
                }
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    
    func testRemoveScheduledTransferWS(){
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let getScheduledTransfersResponse = try bsanTransfersManager!.loadScheduledTransfers(account: account, amountFrom: nil, amountTo: nil, pagination: nil)
            
            if let scheduledTransfer = try getScheduledTransfersResponse.getResponseData()?.transactionDTOs[0] {
                let getScheduledTransferDetaiResponse = try bsanTransfersManager!.getScheduledTransferDetail(account: account, transferScheduledDTO: scheduledTransfer)
                if getScheduledTransferDetaiResponse.isSuccess() {
                    //let scheduledTransferDetail = getScheduledTransferDetaiResponse.getResponseData()
                    
                    let responseSignature = try bsanSignatureManager!.consultScheduledSignaturePositions()
                    var signatureWithTokenDTO = try responseSignature.getResponseData()
                    TestUtils.fillSignature(input: &signatureWithTokenDTO)
                        
                    let removeScheduledTransfer = try bsanTransfersManager!.removeScheduledTransfer(accountDTO: account, orderIbanDTO: getScheduledTransferDetaiResponse.getResponseData()!.iban ?? IBANDTO(), transferScheduledDTO: scheduledTransfer, signatureWithTokenDTO: signatureWithTokenDTO!)
                    if removeScheduledTransfer.isSuccess() {
                        logTestSuccess(result: getScheduledTransferDetaiResponse, function: #function)
                        return
                    }
                    
                    logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                    return
                }
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }

}



