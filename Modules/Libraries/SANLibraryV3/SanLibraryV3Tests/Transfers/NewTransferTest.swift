import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class NewTransferTest: BaseLibraryTests {
    typealias T = TransferDTO
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testTransferTypeWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let transferTypeResponse = try bsanTransfersManager!.transferType(originAccountDTO: account, selectedCountry: "CA", selectedCurrerncy: "CAD")
            guard let typeResponse = try getResponseData(response: transferTypeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - transferType", function: #function)
                return
            }
            
            logTestSuccess(result: typeResponse, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidationSwiftWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let transferTypeResponse = try bsanTransfersManager!.validateSwift(noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account))
            guard let typeResponse = try getResponseData(response: transferTypeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - validateSwift", function: #function)
                return
            }
            
            logTestSuccess(result: typeResponse, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidationIntNoSEPAWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let transferTypeResponse = try bsanTransfersManager!.validationIntNoSEPA(noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account), validationSwiftDTO: TestUtils.getValidationSwiftDTO())
            guard let typeResponse = try getResponseData(response: transferTypeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - validationIntNoSEPA", function: #function)
                return
            }
            
            logTestSuccess(result: typeResponse, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidacionOTPNoSEPAWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let transferTypeResponse = try bsanTransfersManager!.validationIntNoSEPA(noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account), validationSwiftDTO: TestUtils.getValidationSwiftDTO())
            guard let typeResponse = try getResponseData(response: transferTypeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - validationIntNoSEPA", function: #function)
                return
            }
            
            let transferValidationResponse = try bsanTransfersManager!.validationOTPIntNoSEPA(validationIntNoSepaDTO: typeResponse, noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account))
            guard let otpResponse = try getResponseData(response: transferValidationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - ValidacionOTPNoSEPA", function: #function)
                return
            }
            
            logTestSuccess(result: otpResponse, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmationIntNoSEPAWS() {
        do{
            guard let account: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else {
                logTestError(errorMessage: "NOT ACCOUNT", function: #function)
                return
            }
            
            let transferTypeResponse = try bsanTransfersManager!.validationIntNoSEPA(noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account), validationSwiftDTO: TestUtils.getValidationSwiftDTO())
            guard let validationIntNoSepaDTO = try getResponseData(response: transferTypeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - validationIntNoSEPA", function: #function)
                return
            }
            
            let transferValidationResponse = try bsanTransfersManager!.validationOTPIntNoSEPA(validationIntNoSepaDTO: validationIntNoSepaDTO, noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account))
            guard let otpValidationDTO = try getResponseData(response: transferValidationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - ValidacionOTPNoSEPA", function: #function)
                return
            }
            
            let transferConfirmationResponse = try bsanTransfersManager!.confirmationIntNoSEPA(validationIntNoSepaDTO: validationIntNoSepaDTO, validationSwiftDTO: nil, noSepaTransferInput: TestUtils.getNoSEPATransferInput(originAccount: account), otpValidationDTO: otpValidationDTO, otpCode: "", countryCode: "US", aliasPayee: "AAAAAAAAAA TEST IOS NUEVO ALIAS BIC", isNewPayee: true, trusteerInfo: nil)
            guard let confirmResponse = try getResponseData(response: transferConfirmationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA - ConfirmacionIntNoSEPA", function: #function)
                return
            }
            
            logTestSuccess(result: confirmResponse, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
}






