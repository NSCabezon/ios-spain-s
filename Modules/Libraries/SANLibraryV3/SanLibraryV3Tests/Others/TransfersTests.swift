import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class TransfersTests: BaseLibraryTests {
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.iñaki)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testValidateNationalTransfer(){
        
        do{
            
            guard let originAccount: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let validateNationalTransferResponse = try bsanTransfersManager!.validateGenericTransfer(originAccountDTO: originAccount, nationalTransferInput: TestUtils.getNationalTransferInputData())

            guard let validateNationalTransfer = try getResponseData(response: validateNationalTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }

            logTestSuccess(result: validateNationalTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateAccountTransfer(){
        
        do{
            
            guard let originAccount: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            guard let destinationAccount: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else{
                return
            }
            
            let validateAccountTransferResponse = try bsanTransfersManager!.validateAccountTransfer(originAccountDTO: originAccount, destinationAccountDTO: destinationAccount, accountTransferInput: TestUtils.getAccountTransferInputData())
            
            guard let validateAccountTransfer = try getResponseData(response: validateAccountTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateAccountTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateUsualTransferOld(){
        
        do{
            
            guard let originAccount: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let _ = try bsanTransfersManager!.loadUsualTransfersOld()
            let getUsualTransfersResponse = try bsanTransfersManager!.getUsualTransfers()

            guard let getUsualTransfers = try getResponseData(response: getUsualTransfersResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let getUsualTransfer = getUsualTransfers.first else{
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let validateAccountTransferResponse = try bsanTransfersManager!.validateUsualTransfer(originAccountDTO: originAccount, usualTransferInput: TestUtils.getUsualTransferInputData(), transferDTO: getUsualTransfer)
            
            guard let validateAccountTransfer = try getResponseData(response: validateAccountTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateAccountTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateUsualTransfer(){
        
        do{
            
            guard let originAccount: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let getUsualTransfersResponse = try bsanTransfersManager!.getUsualTransfers()
            
            guard
                let getUsualTransfers = try getResponseData(response: getUsualTransfersResponse),
                getUsualTransfers.count >= 3
            else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let getUsualTransfer: TransferDTO = getUsualTransfers[2]
            
            let validateAccountTransferResponse = try bsanTransfersManager!.validateUsualTransfer(originAccountDTO: originAccount, usualTransferInput: TestUtils.getUsualTransferInputData(), transferDTO: getUsualTransfer)
            
            guard let validateAccountTransfer = try getResponseData(response: validateAccountTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateAccountTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSepaPayeeDetail(){
        do{
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let favorite = try bsanTransfersManager!.getUsualTransfers().getResponseData()![1]
            let validateAccountTransferResponse = try bsanTransfersManager!.sepaPayeeDetail(of: favorite.beneficiary!, recipientType: favorite.recipientType!)
            
            guard let validateAccountTransfer = try getResponseData(response: validateAccountTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateAccountTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateCreateSepaPayee(){
        do{
            let beneficiaryName = "New beneficiary"
            let alias = "new alias"
            let iban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let operationDate = Date()
            let validateCreateSepaPayeeResponse = try bsanTransfersManager!.validateCreateSepaPayee(of: alias, recipientType: .national, beneficiary: beneficiaryName, iban: iban, operationDate: operationDate)
            
            guard let validateUpdateSepaPayee = try getResponseData(response: validateCreateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validateUpdateSepaPayee, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateCreateSepaPayeeOTP() {
        do {
            let beneficiaryName = "New beneficiary"
            let alias = "new alias"
            let iban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let operationDate = Date()
            let validateCreateSepaPayeeResponse = try bsanTransfersManager!.validateCreateSepaPayee(of: alias, recipientType: .national, beneficiary: beneficiaryName, iban: iban, operationDate: operationDate)
            
            guard var signatureWithTokenDTO = try getResponseData(response: validateCreateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            signatureWithTokenDTO.signatureDTO?.values = ["2", "2", "2", "2"]
            
            let response = try bsanTransfersManager!.validateCreateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard response.isSuccess() else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmCreateSepaPayee() {
        do {
            let beneficiaryName = "New beneficiary"
            let alias = "new alias"
            let iban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let operationDate = Date()
            let validateCreateSepaPayeeResponse = try bsanTransfersManager!.validateCreateSepaPayee(of: alias, recipientType: .national, beneficiary: beneficiaryName, iban: iban, operationDate: operationDate)

            guard var signatureWithTokenDTO = try getResponseData(response: validateCreateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if signatureWithTokenDTO.signatureDTO == nil {
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)
            
            let validateOTPResponse = try bsanTransfersManager!.validateCreateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard validateOTPResponse.isSuccess() else {
                logTestError(errorMessage: try validateOTPResponse.getErrorMessage(), function: #function)
                return
            }
            
            guard let validateOTPResponseData = try getResponseData(response: validateOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanTransfersManager!.confirmCreateSepaPayee(otpValidationDTO: validateOTPResponseData, otpCode: "")
            guard confirmOTPResponse.isSuccess() else {
                logTestError(errorMessage: try confirmOTPResponse.getErrorMessage(), function: #function)
                return
            }
            
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateRemoveSepaPayee(){
        do {
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let transferDTO = try bsanTransfersManager!.getUsualTransfers().getResponseData()![3]
            
            let validateRemoveSepaPayeeResponse = try bsanTransfersManager!.validateRemoveSepaPayee(ofAlias: transferDTO.beneficiary!, payeeCode: transferDTO.codPayee!, recipientType: transferDTO.recipientType!, accountType: transferDTO.accountType!)
            
            guard let validateRemoveSepaPayee = try getResponseData(response: validateRemoveSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validateRemoveSepaPayee, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateUpdateSepaPayee(){
        do{
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let transferDTO = try bsanTransfersManager!.getUsualTransfers().getResponseData()![1]
            
            let newBeneficiaryName = "Cambio de nombre beneficiario"
            let newIban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let currencyDTO = CurrencyDTO(currencyName: "EUR", currencyType: CurrencyType.eur)
            let validateUpdateSepaPayeeResponse = try bsanTransfersManager!.validateUpdateSepaPayee(transferDTO: transferDTO, newCurrencyDTO: currencyDTO, newBeneficiaryBAOName: newBeneficiaryName, newIban: newIban)
            
            guard let validateUpdateSepaPayee = try getResponseData(response: validateUpdateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: validateUpdateSepaPayee, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateUpdateSepaPayeeOTP() {
        do {
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let transferDTO = try bsanTransfersManager!.getUsualTransfers().getResponseData()![1]
            
            let newBeneficiaryName = "Cambio de nombre beneficiario"
            let newIban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let currencyDTO = CurrencyDTO(currencyName: "EUR", currencyType: CurrencyType.eur)
            let validateUpdateSepaPayeeResponse = try bsanTransfersManager!.validateUpdateSepaPayee(transferDTO: transferDTO, newCurrencyDTO: currencyDTO, newBeneficiaryBAOName: newBeneficiaryName, newIban: newIban)
            
            guard var signatureWithTokenDTO = try getResponseData(response: validateUpdateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            signatureWithTokenDTO.signatureDTO?.values = ["2", "2", "2", "2"]
            
            let response = try bsanTransfersManager!.validateUpdateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard response.isSuccess() else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmUpdateSepaPayee() {
        do {
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let transferDTO = try bsanTransfersManager!.getUsualTransfers().getResponseData()![1]
            
            let newBeneficiaryName = "Cambio de nombre beneficiario"
            let newIban = IBANDTO(countryCode: "ES", checkDigits: "55", codBban: "0049007201211045830")
            let currencyDTO = CurrencyDTO(currencyName: "EUR", currencyType: CurrencyType.eur)
            let validateUpdateSepaPayeeResponse = try bsanTransfersManager!.validateUpdateSepaPayee(transferDTO: transferDTO, newCurrencyDTO: currencyDTO, newBeneficiaryBAOName: newBeneficiaryName, newIban: newIban)
            
            guard var signatureWithTokenDTO = try getResponseData(response: validateUpdateSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            if signatureWithTokenDTO.signatureDTO == nil {
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)
            
            let validateOTPResponse = try bsanTransfersManager!.validateUpdateSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard validateOTPResponse.isSuccess() else {
                logTestError(errorMessage: try validateOTPResponse.getErrorMessage(), function: #function)
                return
            }
            
            guard let validateOTPResponseData = try getResponseData(response: validateOTPResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanTransfersManager!.confirmUpdateSepaPayee(otpValidationDTO: validateOTPResponseData, otpCode: "")
            guard confirmOTPResponse.isSuccess() else {
                logTestError(errorMessage: try confirmOTPResponse.getErrorMessage(), function: #function)
                return
            }
            
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmUpdateSepaPayeeOTPCode() {
        do {
            let otpValidation = OTPValidationDTO(token: "MTU2MTM5MTU5Njc2OSMxNzIuMjEuMjI2LjcjMDBBQUFFODYjMSNQRDk0Yld3Z2RtVnljMmx2YmowaU1TNHdJaUJsYm1OdlpHbHVaejBpVlZSR0xUZ2lQejQ4Wm1seWJXRk5iMlJwWmxCaGVXVmxVMlZ3WVV4cFl6NDhhV0poYmo0OFVFRkpVejVGVXp3dlVFRkpVejQ4UkVsSFNWUlBYMFJGWDBOUFRsUlNUMHcrTlRVOEwwUkpSMGxVVDE5RVJWOURUMDVVVWs5TVBqeERUMFJDUWtGT1BqQXdORGt3TURjeU1ERXlNVEV3TkRVNE16QWdJQ0FnSUNBZ0lDQWdJRHd2UTA5RVFrSkJUajQ4TDJsaVlXNCtQRzV2YldKeVpVSmxibVZtYVdOcFlYSnBiejVEWVcxaWFXOGdaR1VnYm05dFluSmxJR0psYm1WbWFXTnBZWEpwYnp3dmJtOXRZbkpsUW1WdVpXWnBZMmxoY21sdlBqeGhiR2xoY3o1QlRFVk5RVTQ4TDJGc2FXRnpQangwYVhCdlJHVnpkR2x1WVhSaGNtbHZQakF5UEM5MGFYQnZSR1Z6ZEdsdVlYUmhjbWx2UGp4aFkzUjFZVzUwWlVKbGJtVm1hV05wWVhKcGJ6NDhWRWxRVDE5RVJWOUJRMVJWUVU1VVJUNDhSVTFRVWtWVFFUNHdNRFE1UEM5RlRWQlNSVk5CUGp4RFQwUmZWRWxRVDE5RVJWOUJRMVJWUVU1VVJUNUdRand2UTA5RVgxUkpVRTlmUkVWZlFVTlVWVUZPVkVVK1BDOVVTVkJQWDBSRlgwRkRWRlZCVGxSRlBqeE9WVTFGVWs5ZlJFVmZRVU5VVlVGT1ZFVStOREl3TURBeE1URXpNell5TnpjMlBDOU9WVTFGVWs5ZlJFVmZRVU5VVlVGT1ZFVStQQzloWTNSMVlXNTBaVUpsYm1WbWFXTnBZWEpwYno0OGFXMXdiM0owWlQ0OFNVMVFUMUpVUlQ0d0xqQXdQQzlKVFZCUFVsUkZQanhFU1ZaSlUwRStSVlZTUEM5RVNWWkpVMEUrUEM5cGJYQnZjblJsUGp4bVpXTm9ZVTl3WlhKaFkybHZiajR4T1Mwd01pMHlNREU1UEM5bVpXTm9ZVTl3WlhKaFkybHZiajQ4WTI5dVkyVndkRzgrSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQWdJQ0FnSUNBZ0lDQThMMk52Ym1ObGNIUnZQanhqYkdsbGJuUmxSWGhqWlhCMGRXRmtiejQ4TDJOc2FXVnVkR1ZGZUdObGNIUjFZV1J2UGp4cGJtUnBZMkZrYjNKRVlYUnZjMDF2WkdsbWFXTmhaRzl6UGpJOEwybHVaR2xqWVdSdmNrUmhkRzl6VFc5a2FXWnBZMkZrYjNNK1BDOW1hWEp0WVUxdlpHbG1VR0Y1WldWVFpYQmhUR2xqUGc9PSNOT1QgVVNFRCNOT1QgVVNFRCNjYW5hbGVzU0FOUFJFX1NIQTF3aXRoUlNBI3JHWG5panZHRmNRS2dnUitnblhTL1lZaEpVeXluUmdJTHlpWjR1b2xEQ0lsaUYrN2xQUzI4a2w5MGVlR1ZPbU5lSGE4alJHOHdUVDJ1S2UwY0FnLzhIalJXcWhSVStyckhsdXJGSWNhdDV1eVdQc0lieDY2VVhDRkhzL205djAyKzd6WlhCbytwRE5NaTMvenAzdzczNmdMMU9zSEZDNkVxVkV3aTNiY1VzQT0=", ticket: "252326AAAE86", otpExcepted: false)
            let confirmOTPResponse = try bsanTransfersManager!.confirmUpdateSepaPayee(otpValidationDTO: otpValidation, otpCode: "J082J014")
            guard confirmOTPResponse.isSuccess() else {
                logTestError(errorMessage: try confirmOTPResponse.getErrorMessage(), function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }

    func testCheckEntityAdhered(){
        
        do{
            guard let originAccount: AccountDTO = getElementForTesting(orderInArray: 4, function: #function) else{
                return
            }
            
//            guard let destinationAccount: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else{
//                return
//            }

            guard let checkEntityAdheredResponse = try bsanTransfersManager?.checkEntityAdhered(genericTransferInput: TestUtils.getInstantTransferInputData()) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let _ = try getResponseData(response: checkEntityAdheredResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validateGenericTransferResponse = try bsanTransfersManager?.validateGenericTransfer(originAccountDTO: originAccount, nationalTransferInput: TestUtils.getInstantTransferInputData()) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validateGenericTransfer = try getResponseData(response: validateGenericTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateGenericTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testCheckTransferStatus(){
        
        do{
            
            guard let checkTransferStatusResponse = try bsanTransfersManager?.checkTransferStatus(referenceDTO: ReferenceDTO()) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let checkTransferStatus = try getResponseData(response: checkTransferStatusResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: checkTransferStatus, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testNoSepaPayeeDetail(){
        do{
            let _ = try bsanTransfersManager!.loadUsualTransfers()
            let favorite = try bsanTransfersManager!.getUsualTransfers().getResponseData()![1]
            let validateAccountTransferResponse = try bsanTransfersManager!.noSepaPayeeDetail(of: "AAAAAAAAAA TEST IOS NUEVO ALIAS @", recipientType: favorite.recipientType!)
            
            guard let validateAccountTransfer = try getResponseData(response: validateAccountTransferResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: validateAccountTransfer, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateCreateNoSepaPayee(){
        do{
            let alias = "AAAAAAA Test iOS Alta No Sepa 3"
            let noSepaPayeeDTO = NoSepaPayeeDTO(
                swiftCode: nil,
                paymentAccountDescription: "400808595",
                name: "Name beneficiary with Bank Data",
                town: "Chicago",
                address: "Street Chicago",
                countryName: "Estados Unidos",
                countryCode: "US",
                bankName: "JP MORGAN CHASE BANK, N.A.",
                bankAddress: "Street ",
                bankTown: "Location",
                bankCountryCode: "US",
                bankCountryName: nil)
            
            let currencyDTO = CurrencyDTO(currencyName: CurrencyType.dollar.rawValue, currencyType: CurrencyType.dollar)
            
            let validateCreateNoSepaPayeeResponse = try bsanTransfersManager!.validateCreateNoSepaPayee(
                newAlias: alias,
                newCurrency: currencyDTO,
                noSepaPayeeDTO: noSepaPayeeDTO)
            
            guard var signatureWithTokenDTO = try getResponseData(response: validateCreateNoSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            if signatureWithTokenDTO.signatureDTO == nil {
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)
            
            let response = try bsanTransfersManager!.validateCreateNoSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard let validateOTPResponseData = try getResponseData(response: response) else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanTransfersManager!.confirmCreateNoSepaPayee(otpValidationDTO: validateOTPResponseData, otpCode: "")
            guard confirmOTPResponse.isSuccess(), let confirmCreateNoSepaOTP = try getResponseData(response: confirmOTPResponse) else {
                logTestError(errorMessage: try confirmOTPResponse.getErrorMessage(), function: #function)
                return
            }
            logTestSuccess(result: confirmCreateNoSepaOTP.codPayee, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateUpdateNoSepaPayee(){
        do{
            let alias = "AAAAAAA Test iOS Alta No Sepa 3"
            let noSepaPayeeDTO = NoSepaPayeeDTO(
                swiftCode: nil,
                paymentAccountDescription: "400808595",
                name: "Name beneficiary with Bank Data 1",
                town: "Chicago",
                address: "Street Chicago",
                countryName: "Estados Unidos",
                countryCode: "US",
                bankName: "JP MORGAN CHASE BANK, N.A.",
                bankAddress: nil,
                bankTown: nil,
                bankCountryCode: "US",
                bankCountryName: nil)
            
            let currencyDTO = CurrencyDTO(currencyName: "CAD", currencyType: CurrencyType.other)
            
            let validateUpdateNoSepaPayeeResponse = try bsanTransfersManager!.validateUpdateNoSepaPayee(
                alias: alias,
                noSepaPayeeDTO: noSepaPayeeDTO,
                newCurrencyDTO: currencyDTO)
            
            guard var signatureWithTokenDTO = try getResponseData(response: validateUpdateNoSepaPayeeResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            if signatureWithTokenDTO.signatureDTO == nil {
                logTestError(errorMessage: "NO SIGNATURE", function: #function)
                return
            }
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)
            
            let response = try bsanTransfersManager!.validateUpdateNoSepaPayeeOTP(signatureWithTokenDTO: signatureWithTokenDTO)
            guard let validateOTPResponseData = try getResponseData(response: response) else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            
            let confirmOTPResponse = try bsanTransfersManager!.confirmUpdateNoSepaPayee(otpValidationDTO: validateOTPResponseData, otpCode: "")
            guard confirmOTPResponse.isSuccess() else {
                logTestError(errorMessage: try confirmOTPResponse.getErrorMessage(), function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
}
