import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib
class BSANBillAndTaxesTest: BaseLibraryTests {
    typealias T = AccountDTO
    
    let billAndTaxesBarcode = "9050700332001023201554248121800000000000330030"
    
    override func setUp() {
        setLoginUser(newLoginUser: LOGIN_USER.EASY_PAY)
        resetDataRepository()
        super.setUp()
    }
    
    override func getElements<T>(_ sessionData: SessionData) -> [T]? {
        return sessionData.globalPositionDTO.accounts as? [T]
    }
    
    func testValidateBillAndTaxes(){
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let response = try bsanBillTaxesManager!.validateBillAndTaxes(accountDTO: accountDTO, barCode: billAndTaxesBarcode)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: responseData, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSignatureBillAndTaxes(){
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                return
            }
            
            let response = try bsanBillTaxesManager!.consultSignatureBillAndTaxes(chargeAccountDTO: accountDTO, directDebit: true, amountDTO: FieldsUtils.amountDTO)
            
            guard var signatureWithTokenDTO = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA CONSULT", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)

            let confirmationResponse = try bsanBillTaxesManager!.confirmationSignatureBillAndTaxes(signatureWithTokenDTO: signatureWithTokenDTO)
            
            guard let responseData = try getResponseData(response: confirmationResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA CONFIRM", function: #function)
                return
            }
            
            logTestSuccess(result: responseData, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmBillAndTaxes(){
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 0, function: #function) else{
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            
            _ = try bsanBillTaxesManager!.validateBillAndTaxes(accountDTO: accountDTO, barCode: billAndTaxesBarcode)
            
            let responseConsultSignature = try bsanBillTaxesManager!.consultSignatureBillAndTaxes(chargeAccountDTO: accountDTO, directDebit: true, amountDTO: FieldsUtils.amountDTO)
            
            guard var signatureWithTokenDTO = try getResponseData(response: responseConsultSignature) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA CONSULT", function: #function)
                return
            }
            
            TestUtils.fillSignature(input: &signatureWithTokenDTO.signatureDTO)

            _ = try bsanBillTaxesManager!.confirmationSignatureBillAndTaxes(signatureWithTokenDTO: signatureWithTokenDTO)
            
            guard let billAndTaxesInfo = getSessionData()?.billAndTaxesInfo else {
                logTestError(errorMessage: "NO BILL AND TAXES INFO", function: #function)
                return
            }
            
            guard let paymentBillTaxesDTO = billAndTaxesInfo.paymentBillTaxesDTO else {
                logTestError(errorMessage: "NO PAYMENT BILL TAXES DTO", function: #function)
                return
            }
            
            guard let billAndTaxesTokenDTO = billAndTaxesInfo.billAndTaxesTokenDTO else {
                logTestError(errorMessage: "NO BILL AND TAXES TOKEN", function: #function)
                return
            }
            
            let response = try bsanBillTaxesManager!.confirmationBillAndTaxes(chargeAccountDTO: accountDTO, paymentBillTaxesDTO: paymentBillTaxesDTO, billAndTaxesTokenDTO: billAndTaxesTokenDTO, directDebit: false)
            
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: responseData, function: #function)

        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testLoadBills() {
        do {
            try loadBills()
        } catch {
            logTestException(error: error, function: #function)
        }
    }

    func loadBills(pagination: PaginationDTO? = nil) throws {
        guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
            logTestError(errorMessage: "NO ACCOUNT", function: #function)
            return
        }
        let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
        let toDate = Date()
        let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: pagination, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
        guard let responseData = try getResponseData(response: response) else {
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
            return
        }
        guard let pagination = responseData.pagination, !pagination.endList else {
            logTestSuccess(result: responseData, function: #function)
            return
        }
        try loadBills(pagination: responseData.pagination)
    }
    
    func testCancelDirectBilling() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseCancel = try bsanBillTaxesManager!.cancelDirectBilling(account: accountDTO, bill: myBill)
            guard let responseCancelData = try getResponseData(response: responseCancel) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CANCEL DATA", function: #function)
                return
            }
            logTestSuccess(result: responseCancel, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }

    func testConfirmCancelDirectBilling() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseCancel = try bsanBillTaxesManager!.cancelDirectBilling(account: accountDTO, bill: myBill)
            guard let getCancelDirectBillingDTO = try getResponseData(response: responseCancel) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CANCEL DATA", function: #function)
                return
            }
            var signatureDTO = getCancelDirectBillingDTO.signature
            TestUtils.fillSignature(input: &signatureDTO)
            
            guard let confirmCancelDirectBilling = try bsanBillTaxesManager?.confirmCancelDirectBilling(account: accountDTO, bill: myBill, signature: signatureDTO!, getCancelDirectBillingDTO: getCancelDirectBillingDTO) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CONFIRM CANCEL DATA", function: #function)
                return
            }
            logTestSuccess(result: responseCancel, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testDuplicateBill() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseDuplicate = try bsanBillTaxesManager!.duplicateBill(account: accountDTO, bill: myBill)
            guard let responseDuplicateData = try getResponseData(response: responseDuplicate) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CANCEL DATA", function: #function)
                return
            }
            logTestSuccess(result: responseDuplicateData, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmDuplicateBill() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseDuplicate = try bsanBillTaxesManager!.duplicateBill(account: accountDTO, bill: myBill)
            guard let responseDuplicateData = try getResponseData(response: responseDuplicate) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DUPLICATE DATA", function: #function)
                return
            }
            var signatureDTO: SignatureDTO? = responseDuplicateData.signature
            TestUtils.fillSignature(input: &signatureDTO)
            guard let confirmDuplicateBill =  try bsanBillTaxesManager?.confirmDuplicateBill(account: accountDTO, bill: myBill, signature: signatureDTO!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CONFIRM DUPLICATE DATA", function: #function)
                return
            }
            let _ = try getResponseData(response: confirmDuplicateBill)
            logTestSuccess(result: confirmDuplicateBill, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testConfirmReceiptReturn() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO FOUND ACCOUNT", function: #function)
                return
            }
            guard let bsanBillTaxesManager = bsanBillTaxesManager else {
                logTestError(errorMessage: "NO FOUND BsanBillTaxesManager", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "FAIL loadBills()", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseDetail = try bsanBillTaxesManager.billAndTaxesDetail(of: accountDTO, bill: myBill, enableBillAndTaxesRemedy: false)
            guard let responseDetailData = try getResponseData(response: responseDetail) else {
                logTestError(errorMessage: "FAIL billAndTaxesDetail()", function: #function)
                return
            }
            var signatureDTO: SignatureDTO? = responseDetailData.signature
            TestUtils.fillSignature(input: &signatureDTO)
            guard let signature = signatureDTO else {
                logTestError(errorMessage: "NO FOUND SIGNATURE", function: #function)
                return
            }
            let confirmReceiptReturn = try bsanBillTaxesManager.confirmReceiptReturn(account: accountDTO, bill: myBill, billDetail: responseDetailData, signature: signature)
            guard confirmReceiptReturn.isSuccess() else {
                logTestError(errorMessage: "FAIL confirmReceiptReturn()", function: #function)
                return
            }
            let _ = try getResponseData(response: confirmReceiptReturn)
            logTestSuccess(result: confirmReceiptReturn, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testBillAndTaxesDetailRequest() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let listResponse = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: listResponse) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let testBill = responseData.bills[0]
            let response = try bsanBillTaxesManager!.billAndTaxesDetail(of: accountDTO, bill: testBill, enableBillAndTaxesRemedy: false)
            guard let responseDetailData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            logTestSuccess(result: responseDetailData, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }

    func testConfirmChangeDirectDebit() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else {
                logTestError(errorMessage: "NO FOUND ACCOUNT", function: #function)
                return
            }
            guard let accountDestinationDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO FOUND ACCOUNT", function: #function)
                return
            }
            guard let bsanBillTaxesManager = bsanBillTaxesManager else {
                logTestError(errorMessage: "NO FOUND BsanBillTaxesManager", function: #function)
                return
            }
            guard let bsanSignatureManager = bsanSignatureManager else {
                logTestError(errorMessage: "NO FOUND BsanSignatureManager", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "FAIL loadBills()", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseSignature = try bsanSignatureManager.consultBillAndTaxesSignaturePositions()
            guard let responseSignatureData = try getResponseData(response: responseSignature) else {
                logTestError(errorMessage: "FAIL consultBillAndTaxesSignaturePositions()", function: #function)
                return
            }
            var signatureDTO: SignatureWithTokenDTO? = responseSignatureData
            TestUtils.fillSignature(input: &signatureDTO)
            guard let signature = signatureDTO else {
                logTestError(errorMessage: "NO FOUND SIGNATURE", function: #function)
                return
            }
            let confirmReceiptReturn = try bsanBillTaxesManager.confirmChangeDirectDebit(account: accountDestinationDTO, bill: myBill, signature: signature)
            guard confirmReceiptReturn.isSuccess() else {
                logTestError(errorMessage: "FAIL confirmChangeDirectDebit()", function: #function)
                return
            }
            let _ = try getResponseData(response: confirmReceiptReturn)
            logTestSuccess(result: confirmReceiptReturn, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testDownloadPdfBill() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let fromDate = Date().addingTimeInterval(-3600 * 24 * 31 * 2)
            let toDate = Date()
            let response = try bsanBillTaxesManager!.loadBills(of: accountDTO, pagination: nil, from: DateModel(date: fromDate), to: DateModel(date: toDate), status: .all)
            guard let responseData = try getResponseData(response: response) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let myBill = responseData.bills[0]
            let responseDownload = try bsanBillTaxesManager!.downloadPdfBill(account: accountDTO, bill: myBill)
            guard let responseDownloadData = try getResponseData(response: responseDownload) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE CANCEL DATA", function: #function)
                return
            }
            logTestSuccess(result: responseDownload, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateChangeMassiveDirectDebitsAccount() {
        do {
            logTestSuccess(result: try validateChangeMassiveDirectDebitsAccount(), function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func validateChangeMassiveDirectDebitsAccount() throws -> SignatureWithTokenDTO {
        // To test, switch between 1 and 2 once the account has been changed
        guard let originAccountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function), let destinationAccountDTO: AccountDTO = getElementForTesting(orderInArray: 1 , function: #function) else {
            throw BSANException("NO ACCOUNT")
        }
        let response = try bsanBillTaxesManager!.validateChangeMassiveDirectDebitsAccount(originAccount: originAccountDTO, destinationAccount: destinationAccountDTO)
        guard let responseData = try getResponseData(response: response) else {
            throw BSANException("RETURNED NO RESPONSE DATA")
        }
        return responseData
    }
    
    func testConfirmChangeMassiveDirectDebitsAccount() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 2, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            var signatureWithToken: SignatureWithTokenDTO? = try validateChangeMassiveDirectDebitsAccount()
            TestUtils.fillSignature(input: &signatureWithToken)
            let response = try bsanBillTaxesManager!.confirmChangeMassiveDirectDebitsAccount(originAccount: accountDTO, signature: signatureWithToken!)
            guard response.isSuccess() else {
                logTestError(errorMessage: try response.getErrorCode(), function: #function)
                return
            }
            logTestSuccess(result: true, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    func testEmittersConsult() {
        do {
            guard let accountDTO: AccountDTO = getElementForTesting(orderInArray: 1, function: #function) else {
                logTestError(errorMessage: "NO ACCOUNT", function: #function)
                return
            }
            let params = EmittersConsultParamsDTO(
                account: accountDTO,
                emitterName: "IBER",
                emitterCode: "",
                pagination: EmittersPaginationAdapter(pagination: nil))
            
            let response = try bsanBillTaxesManager!.emittersConsult(params: params)
            guard response.isSuccess() else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            guard let emittersConsult = try response.getResponseData() else {
                logTestError(errorMessage: try response.getErrorMessage(), function: #function)
                return
            }
            XCTAssertNotNil(emittersConsult)
        }catch {
            logTestException(error: error, function: #function)
        }
    }
}
