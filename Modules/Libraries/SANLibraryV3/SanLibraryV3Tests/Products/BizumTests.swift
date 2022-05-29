import XCTest
@testable import SanLibraryV3
import Alamofire
import Alamofire_Synchronous
import CoreFoundationLib

class BizumTests: BaseLibraryTests {
    
    override func setUp() {
        //        isPb = true
        environmentDTO = BSANEnvironments.enviromentPreWas9
        setLoginUser(newLoginUser: LOGIN_USER.BIZUM_HISTORIC)
        resetDataRepository()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetContacts() {
        //        "https://sanesp-pre.pru.bsch/bizum/contacts"
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let contacts = try bsanBizumManager?.getContacts(BizumGetContactsInputParams(checkPayment: bizumCheckPaymentDTO, contactList: [
                "+34661727679",
                "+34638232081",
                "+34655107541",
                "+34655107540",
                "+34652832014",
                "+34657548312",
                "+34669693942"
            ]))
            if contacts == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumGetContactsDTO = try getResponseData(response: contacts!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumGetContactsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testCheckPayment() {
        //        "https://sanesp-pre.pru.bsch/payments/check-payment"
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumCheckPaymentDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testBizumValidateTransfer() {
        //      "https://sanesp-pre.pru.bsch/api/v1/bizum-multi/validate-money-transfer"
        do{
            
            let bizumPhone = "+34655107541"
            guard let params = try getParamsForValidateTransfer(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            
            let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(params)
            if validateMoneyTransfer == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumValidateTransferDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testBizumValidateTransferMulti() {
        //    "https://sanesp-pre.pru.bsch/api/v1/bizum-multi/validate-money-transfer-multi"
        do{
            
            let bizumPhones = ["+34661727679", "+34638232081", "+34655107541"]
            guard let params = try getParamsForValidateTransferMulti(receiverPhones: bizumPhones) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            
            let validateMoneyTransferMulti = try bsanBizumManager?.validateMoneyTransferMulti(params)
            if validateMoneyTransferMulti == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumValidateTransferMultiDTO = try getResponseData(response: validateMoneyTransferMulti!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumValidateTransferMultiDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetSignPositions() {
        // "https://sanesp-pre.pru.bsch/swendi/sign-positions"
        do{
            // Note: language and application are fixed values
            let getSignPositions = try bsanBizumManager?.getSignPositions()
            if getSignPositions == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getPositionsDTO = try getResponseData(response: getSignPositions!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getPositionsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateMoneyTransferOTP() {
        // https://sanesp-pre.pru.bsch/api/v1/bizum-multi/validate-money-transfer-otp
        do{
            let bizumPhone = "+34655107541"
            guard let params = try getParamsForValidateTransferOTP(receiverPhone: bizumPhone, footPrint: nil, deviceToken: nil) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let validateMoneyTransferOTP = try bsanBizumManager?.validateMoneyTransferOTP(params)
            if validateMoneyTransferOTP == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getPositionsDTO = try getResponseData(response: validateMoneyTransferOTP!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getPositionsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateMoneyTransferOTPWtihFootprint() {
        // https://sanesp-pre.pru.bsch/api/v1/bizum-multi/validate-money-transfer-otp
        do{
            let bizumPhone = "+34655107541"
            guard let params = try getParamsForValidateTransferOTP(receiverPhone: bizumPhone, footPrint: "Test", deviceToken: nil) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let validateMoneyTransferOTP = try bsanBizumManager?.validateMoneyTransferOTP(params)
            if validateMoneyTransferOTP == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getPositionsDTO = try getResponseData(response: validateMoneyTransferOTP!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getPositionsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testValidateMoneyTransferOTPWtihDeviceToken() {
        // https://sanesp-pre.pru.bsch/api/v1/bizum-multi/validate-money-transfer-otp
        do{
            let bizumPhone = "+34655107541"
            guard let params = try getParamsForValidateTransferOTP(receiverPhone: bizumPhone, footPrint: nil, deviceToken: "Test") else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let validateMoneyTransferOTP = try bsanBizumManager?.validateMoneyTransferOTP(params)
            if validateMoneyTransferOTP == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getPositionsDTO = try getResponseData(response: validateMoneyTransferOTP!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getPositionsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testMoneyTransferOTP() {
        // https://sanesp-pre.pru.bsch/api/v1/bizum-multi/money-transfer-otp
        do{
            let bizumPhone = "+34655107541"
            guard let params = try getParamsForMoneyTransferOTP(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let moneyTransferOTP = try bsanBizumManager?.moneyTransferOTP(params)
            if moneyTransferOTP == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getResultDTO = try getResponseData(response: moneyTransferOTP!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getResultDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testMoneyTransferMulti() {
        // https://sanesp-pre.pru.bsch/api/v1/bizum-multi/money-transfer-multi
        do{
            let bizumPhones = ["+34661727679", "+34655107541"] // Note: These should be bizum user phones, with "ENVIAR" action
            guard let params = try getParamsForMoneyTransferMulti(receiverPhones: bizumPhones) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let moneyTransferMulti = try bsanBizumManager?.moneyTransferOTPMulti(params)
            if moneyTransferMulti == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getResultDTO = try getResponseData(response: moneyTransferMulti!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getResultDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    // Note: this test generate an SMS when it success
    func testInviteNoClientOTP() {
        // https://sanesp-pre.pru.bsch/bizum/invite-no-client-otp
        do{
            let noBizumPhone = "+34600937932"
            guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: noBizumPhone) else {
                return
            }
            guard let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(validateTranferParams) else {
                return
            }
            guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer) else {
                return
            }
            let inviteNoClient = try bsanBizumManager?.inviteNoClientOTP(BizumInviteNoClientOTPInputParams(validateMoneyTransferDTO: bizumValidateTransferDTO))
            if inviteNoClient == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: inviteNoClient!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }

    func testInviteNoClient() {
        // https://sanesp-pre.pru.bsch/bizum/invite-no-client
        do {
            let noBizumPhone = "+34600937932"
            guard let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001"),
                  let bizumCheckPaymentDTO = try getResponseData(response: checkPayment),
                  let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: noBizumPhone)),
                  let documentDTO = try getResponseData(response: documentResponse),
                  let validateMoneyRequest = try bsanBizumManager?.validateMoneyRequest(BizumValidateMoneyRequestInputParams(checkPayment: bizumCheckPaymentDTO, document: documentDTO, dateTime: Date(), concept: "Test", amount: "10", receiverUserId: noBizumPhone)) else {
                return
            }
            guard let bizumValidateMoneyRequestDTO = try getResponseData(response: validateMoneyRequest) else {
                return
            }
            let inviteNoClient = try bsanBizumManager?.inviteNoClient(BizumInviteNoClientInputParams(validateMoneyRequestDTO: bizumValidateMoneyRequestDTO))
            if inviteNoClient == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: inviteNoClient!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    // MARK: - Money request tests
    func testBizumValidateMoneyRequest() {
        //      "https://sanesp-pre.pru.bsch/api/v1/bizum/validate-money-request"
        do{
            
            let bizumPhone = "+34655107541"
            guard let params = try getValidateMoneyRequestParams(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let validateMoneyRequest = try bsanBizumManager?.validateMoneyRequest(params)
            if validateMoneyRequest == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumValidateMoneyRequestDTO = try getResponseData(response: validateMoneyRequest!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumValidateMoneyRequestDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testBizumMoneyRequest() {
        // https://sanesp-pre.pru.bsch/bizum/money-request
        do {
            let bizumPhone = "+34655107541"
            guard let params = try getMoneyRequestParams(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let moneyRequest = try bsanBizumManager?.moneyRequest(params)
            if moneyRequest == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumMoneyRequestDTO = try getResponseData(response: moneyRequest!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumMoneyRequestDTO, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testBizumValidateMoneyRequestMulti() {
        //    "https://sanesp-pre.pru.bsch/bizum/validate-money-request-multi"
        do{
            
            let bizumPhones = ["+34661727679", "+34638232081", "+34655107541"]
            guard let params = try getValidateMoneyRequestMultiParams(receiverPhones: bizumPhones) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            
            let validateMoneyRequestMulti = try bsanBizumManager?.validateMoneyRequestMulti(params)
            if validateMoneyRequestMulti == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumValidateMoneyRequestMultiDTO = try getResponseData(response: validateMoneyRequestMulti!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumValidateMoneyRequestMultiDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testBizumMoneyRequestMulti() {
        // https://sanesp-pre.pru.bsch/bizum/money-request-multi
        do {
            let bizumPhones = ["+34661727679", "+34638232081", "+34655107541"]
            guard let params = try getMoneyRequestMultiParams(receiversPhones: bizumPhones) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            let moneyRequestMulti = try bsanBizumManager?.moneyRequestMulti(params)
            if moneyRequestMulti == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumMoneyRequestMultiDTO = try getResponseData(response: moneyRequestMulti!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumMoneyRequestMultiDTO, function: #function)
        } catch {
            logTestException(error: error, function: #function)
        }
    }
    
    // MARK: - Multimedia Tests
    func testGetMultimediaContacts() {
        // https://sanesp-pre.pru.bsch/api/v2/bizum-txt-img/get-multimedia-users
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let multimediaCapabilities = try bsanBizumManager?.getMultimediaUsers(BizymMultimediaUsersInputParams(checkPayment: bizumCheckPaymentDTO, contactList: [
                "+34653911094",
                "+34655107450",
                "+34616128627",
                "+34666999888",
                "+34669693942",
                "+34652832014"
            ]))
            if multimediaCapabilities == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumGetMultimediaContactsDTO = try getResponseData(response: multimediaCapabilities!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: bizumGetMultimediaContactsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetMultimediaContent_withoutAdditionalInformation() {
        let operationID = "86281866390013222781644361162055143"
        do {
            guard let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001") else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let multimediaContent = try bsanBizumManager?.getMultimediaContent(BizumMultimediaContentInputParams(checkPayment: bizumCheckPaymentDTO, operationId: operationID)) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getMultimediaContentDTO = try getResponseData(response: multimediaContent) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getMultimediaContentDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testGetMultimediaContent_withAdditionalInformation() {
        let operationID = "22046633234737806562148127564175836"
        do {
            guard let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001") else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let multimediaContent = try bsanBizumManager?.getMultimediaContent(BizumMultimediaContentInputParams(checkPayment: bizumCheckPaymentDTO, operationId: operationID)) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getMultimediaContentDTO = try getResponseData(response: multimediaContent) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getMultimediaContentDTO, function: #function)
            
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    func testSendPNGImageText() {
        // https://sanesp-pre.pru.bsch/api/v2/bizum-txt-img/send-image-text
        do{
            let bizumPhone = "+34653911094" // a bizum client with multimedia capabilities
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let base64Image = getImagePNGforMultimediaRequest()
            let exists = NSPredicate(format: "exists == 1") // We need to wait for the image to load
            let delayExpectation = expectation(for: exists, evaluatedWith: base64Image, handler: nil)
            delayExpectation.isInverted = true
            wait(for: [delayExpectation], timeout: 3)
            
            let base64EncodedString = getTextForMultimediaRequest()
            
            guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(validateTranferParams) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let params = BizumSendMultimediaInputParams(checkPayment: bizumCheckPaymentDTO, validateTransferDTO: bizumValidateTransferDTO, receiverUserId: bizumPhone, image: base64Image, imageFormat: .png, text: base64EncodedString)
            let sendImageText = try bsanBizumManager?.sendImageText(params)
            if sendImageText == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: sendImageText!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSendJPGImageText() {
        // https://sanesp-pre.pru.bsch/api/v2/bizum-txt-img/send-image-text
        do{
            let bizumPhone = "+34653911094" // a bizum client with multimedia capabilities
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let base64Image = getImageJPGforMultimediaRequest()
            let exists = NSPredicate(format: "exists == 1") // We need to wait for the image to load
            let delayExpectation = expectation(for: exists, evaluatedWith: base64Image, handler: nil)
            delayExpectation.isInverted = true
            wait(for: [delayExpectation], timeout: 3)
            
            let base64EncodedString = getTextForMultimediaRequest()
            
            guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(validateTranferParams) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let params = BizumSendMultimediaInputParams(checkPayment: bizumCheckPaymentDTO, validateTransferDTO: bizumValidateTransferDTO, receiverUserId: bizumPhone, image: base64Image, imageFormat: .jpg, text: base64EncodedString)
            let sendImageText = try bsanBizumManager?.sendImageText(params)
            if sendImageText == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: sendImageText!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSendEmptyImageAndText() {
        // https://sanesp-pre.pru.bsch/api/v2/bizum-txt-img/send-image-text
        do{
            let bizumPhone = "+34653911094" // a bizum client with multimedia capabilities
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let base64EncodedString = getTextForMultimediaRequest()
            guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: bizumPhone) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(validateTranferParams) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let params = BizumSendMultimediaInputParams(checkPayment: bizumCheckPaymentDTO, validateTransferDTO: bizumValidateTransferDTO, receiverUserId: bizumPhone, image: "", imageFormat: .noImage, text: base64EncodedString)
            let sendImageText = try bsanBizumManager?.sendImageText(params)
            if sendImageText == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: sendImageText!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testSendImageTextMulti() {
        // https://sanesp-pre.pru.bsch/api/v2/bizum-txt-img/send-image-text
        do{
            let bizumPhones = [
                "+34653911094",
                "+34655107450",
                "+34616128627",
                "+34666999888",
                "+34669693942",
                "+34652832014"
            ]
            
            let base64Image = getImagePNGforMultimediaRequest()
            let exists = NSPredicate(format: "exists == 1") // We need to wait for the image to load
            let delayExpectation = expectation(for: exists, evaluatedWith: base64Image, handler: nil)
            delayExpectation.isInverted = true
            wait(for: [delayExpectation], timeout: 3)
            
            let base64EncodedString = getTextForMultimediaRequest()
            
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            guard let contactsWithMultimediaCapacity = try getReceiverListFromContactsMultimediaCapabilities(phoneList: bizumPhones) else {
                logTestError(errorMessage: "NO CONTACTS WITH MULTIMEDIA CAPABILITIES", function: #function)
                return
            }
            
            guard let validateTranferParams = try getParamsForValidateTransferMulti(receiverPhones: bizumPhones) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA IN TEST DEPENDENCY CALL", function: #function)
                return
            }
            
            let validateMoneyTransferMulti = try bsanBizumManager?.validateMoneyTransferMulti(validateTranferParams)
            if validateMoneyTransferMulti == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumValidateTransferMultiDTO = try getResponseData(response: validateMoneyTransferMulti!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            
            let receiverContacts =  bizumValidateTransferMultiDTO.validationResponseList.filter({ contactsWithMultimediaCapacity.contains($0.identifier) })
                .map { (validatedReceiver) -> BizumMultimediaReceiverInputParam in
                    return BizumMultimediaReceiverInputParam(receiverUserId: validatedReceiver.identifier,
                                                             operationId: validatedReceiver.operationId)
                }
            
            guard receiverContacts.count > 0 else {
                logTestError(errorMessage: "NO receivers with multimedia capabilities and validated", function: #function)
                return
            }
            let params = BizumSendImageTextMultiInputParams(emmiterUserId: bizumCheckPaymentDTO.phone,
                                                            multiOperationId: bizumValidateTransferMultiDTO.multiOperationId,
                                                            operationReceiverList: [],
                                                            image: base64Image,
                                                            imageFormat: .png,
                                                            text: base64EncodedString, operationType: .send)
            let sendImageText = try bsanBizumManager?.sendImageTextMulti(params)
            if sendImageText == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let getInfoDTO = try getResponseData(response: sendImageText!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: getInfoDTO, function: #function)
            
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    // MARK: - Aux methods
    private func getParamsForValidateTransfer(receiverPhone: String) throws -> BizumValidateMoneyTransferInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        return BizumValidateMoneyTransferInputParams(checkPayment: bizumCheckPaymentDTO, document: documentDTO, dateTime: Date(), concept: "Envío de dinero", amount: "3.20", receiverUserId: receiverPhone, account: nil)
    }
    
    private func getParamsForValidateTransferMulti(receiverPhones: [String]) throws -> BizumValidateMoneyTransferMultiInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        return BizumValidateMoneyTransferMultiInputParams(checkPayment: bizumCheckPaymentDTO, document: documentDTO, dateTime: Date(), concept: "Envío de dinero", amount: "3.20", receiverUserIds: receiverPhones, account: nil)
    }
    
    private func getValidateMoneyTransferParams(amount: String, footPrint: String?, deviceToken: String?) throws -> BizumValidateMoneyTransferOTPInputParams? {
        guard
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001"),
            let bizumCheckPaymentDTO = try getResponseData(response: checkPayment),
            let getSignPositions = try bsanBizumManager?.getSignPositions(),
            let signPositionsDTO = try getResponseData(response: getSignPositions)
        else { return nil }
        var signature: SignatureWithTokenDTO? = signPositionsDTO.signature
        TestUtils.fillSignature(input: &signature)
        guard let signatureUnwrapped = signature else {
            return nil
        }
        return BizumValidateMoneyTransferOTPInputParams(checkPayment: bizumCheckPaymentDTO, signatureWithTokenDTO: signatureUnwrapped, amount: Decimal(string: amount) ?? 0, numberOfRecipients: 1, operation: "C2CED", footPrint: footPrint, deviceToken: deviceToken)
    }
    
    private func getParamsForValidateTransferOTP(receiverPhone: String, footPrint: String?, deviceToken: String?) throws -> BizumValidateMoneyTransferOTPInputParams? {
        
        guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: receiverPhone) else {
            return nil
        }
        
        guard (try bsanBizumManager?.validateMoneyTransfer(validateTranferParams)) != nil else {
            return nil
        }
        return try getValidateMoneyTransferParams(amount: validateTranferParams.amount, footPrint: footPrint, deviceToken: deviceToken)
    }
    
    private func getParamsForMoneyTransferOTP(receiverPhone: String) throws -> BizumMoneyTransferOTPInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        guard let validateTranferParams = try getParamsForValidateTransfer(receiverPhone: receiverPhone) else {
            return nil
        }
        
        guard let validateMoneyTransfer = try bsanBizumManager?.validateMoneyTransfer(validateTranferParams) else {
            return nil
        }
        
        guard let bizumValidateTransferDTO = try getResponseData(response: validateMoneyTransfer) else {
            return nil
        }
        
        guard let validateMoneyTransferParams = try getValidateMoneyTransferParams(amount: validateTranferParams.amount, footPrint: nil, deviceToken: nil) else {
            return nil
        }
        
        guard let validateMoneyTransferOTP = try bsanBizumManager?.validateMoneyTransferOTP(validateMoneyTransferParams) else  {
            return nil
        }
        
        guard let getPositionsDTO = try getResponseData(response: validateMoneyTransferOTP) else {
            return nil
        }
        
        // Note: we can't test a case with ticketSN = S because it requires an OTP SMS
        guard getPositionsDTO.ticketSN == "N" else {
            return nil
        }
        return BizumMoneyTransferOTPInputParams(checkPayment: bizumCheckPaymentDTO, otpValidationDTO: getPositionsDTO.otp, document: documentDTO, otpCode: "", validateMoneyTransferDTO: bizumValidateTransferDTO, dateTime: Date(), concept: validateTranferParams.concept, amount: validateTranferParams.amount, receiverUserId: validateTranferParams.receiverUserId, account: nil, tokenPush: nil)
    }
    
    func testOperations() {
        //        "https://sanesp-pre.pru.bsch/payments/check-payment"
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let dateTo = Date()
            let dateFrom = dateTo.addingTimeInterval(-3600 * 24 * 31)
            let operationsResponse = try bsanBizumManager?.getOperations(BizumOperationsInputParams(checkPayment: bizumCheckPaymentDTO, page: 1, dateFrom: dateFrom, dateTo:dateTo, orderBy: "FECHA_ALTA", orderType: "DESC"))
            guard let operationsDTO = try getResponseData(response: operationsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: operationsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testOperationsMulti() {
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let dateTo = Date()
            let dateFrom = dateTo.addingTimeInterval(-3600 * 24 * 31)
            let operationsResponse = try bsanBizumManager?.getListMultipleOperations(BizumOperationListMultipleInputParams(checkPayment: bizumCheckPaymentDTO, formDate: dateFrom, toDate: dateTo, page: 1, elements: 100))
            guard let operationsDTO = try getResponseData(response: operationsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: operationsDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func testOperationsMultiDetail() {
        do{
            let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
            if checkPayment == nil {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let dateTo = Date()
            let dateFrom = dateTo.addingTimeInterval(-3600 * 24 * 31)
            let operationsResponse = try bsanBizumManager?.getListMultipleOperations(BizumOperationListMultipleInputParams(checkPayment: bizumCheckPaymentDTO, formDate: dateFrom, toDate: dateTo, page: 1, elements: 100))
            guard let operationsDTO = try getResponseData(response: operationsResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            guard let operationDTO = operationsDTO.operations.first else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            let operationDetailResponse = try bsanBizumManager?.getListMultipleDetailOperation(BizumOperationMultipleListDetailInputParams(checkPayment: bizumCheckPaymentDTO, operation: operationDTO))
            guard let operationDetailDTO = try getResponseData(response: operationDetailResponse!) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
                return
            }
            logTestSuccess(result: operationDetailDTO, function: #function)
        } catch let error{
            logTestException(error: error, function: #function)
        }
    }
    
    func test_bizum_cancel_not_registered_phone() {
        do {
            guard let cancelBizumInputParam = try self.getOperationsCancelled() else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA -> Cancel Bizum Not Registered. Input params", function: #function)
                return
            }
            guard let infoDTO = try bsanBizumManager?.cancelPendingTransfer(cancelBizumInputParam) else {
                logTestError(errorMessage: "RETURNED NO RESPONSE DATA -> Cancel Bizum Not Registered", function: #function)
                return
            }
            logTestSuccess(result: infoDTO, function: #function)
        } catch let error {
            logTestException(error: error, function: #function)
        }
    }
    
    private func getParamsForMoneyTransferMulti(receiverPhones: [String]) throws -> BizumMoneyTransferOTPMultiInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
            return nil
        }
        
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        
        guard let validateTranferParams = try getParamsForValidateTransferMulti(receiverPhones: receiverPhones) else {
            return nil
        }
        
        guard let validateMoneyTransferMulti = try bsanBizumManager?.validateMoneyTransferMulti(validateTranferParams) else {
            return nil
        }
        
        guard let bizumValidateTransferMultiDTO = try getResponseData(response: validateMoneyTransferMulti) else {
            return nil
        }
        
        guard let validateMoneyTransferParams = try getValidateMoneyTransferParams(amount: validateTranferParams.amount, footPrint: nil, deviceToken: nil) else {
            return nil
        }
        
        guard let validateMoneyTransferOTP = try bsanBizumManager?.validateMoneyTransferOTP(validateMoneyTransferParams) else  {
            return nil
        }
        
        guard let getPositionsDTO = try getResponseData(response: validateMoneyTransferOTP) else {
            return nil
        }
        
        // Note: we can't test a case with ticketSN = S because it requires an OTP SMS
        guard getPositionsDTO.ticketSN == "N" else {
            return nil
        }
        return BizumMoneyTransferOTPMultiInputParams(checkPayment: bizumCheckPaymentDTO, otpValidationDTO: getPositionsDTO.otp, document: documentDTO, otpCode: "", validateMoneyTransferMultiDTO: bizumValidateTransferMultiDTO, dateTime: Date(), concept: validateTranferParams.concept, amount: validateTranferParams.amount, account: nil)
    }
    
    private func getReceiverListFromContactsMultimediaCapabilities(phoneList: [String]) throws -> [String]? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            logTestError(errorMessage: "RETURNED NO RESPONSE DATA", function: #function)
            return nil
        }
        guard let multimediaCapabilities = try bsanBizumManager?.getMultimediaUsers(BizymMultimediaUsersInputParams(checkPayment: bizumCheckPaymentDTO, contactList: phoneList)) else {
            return nil
        }
        
        guard let bizumGetMultimediaContactsDTO = try getResponseData(response: multimediaCapabilities) else {
            return nil
        }
        
        // return the phone only if capabilities are true, leave empty the operation id to fill it later
        return bizumGetMultimediaContactsDTO.contacts
            .filter { $0.capacity == true }
            .map {$0.phone}
    }
    
    private func getImageforMultimediaRequest() -> String {
        var base64Text = ""
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "bizumTest", in: bundle, compatibleWith: nil)
        if let image = testImage {
            let imageData: Data = image.pngData()!
            base64Text = imageData.base64EncodedString()
        }
        return base64Text
    }
    
    
}

private extension BizumTests {
    //The name need .jpg
    func getImageJPGforMultimediaRequest() -> String {
        var base64Text = ""
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "BizumImage.jpg", in: bundle, compatibleWith: nil)
        if let image = testImage {
            let imageData: Data = image.jpegData(compressionQuality: 0) ?? Data()
            let imageSize: Int = imageData.count
            print("Actual size of image in KB:  \(Double(imageSize) / 1000.0)")
            base64Text = imageData.base64EncodedString()
        }
        return base64Text
    }
    
    func getImagePNGforMultimediaRequest() -> String {
        var base64Text = ""
        let bundle = Bundle(for: type(of: self))
        let testImage = UIImage(named: "bizumTest", in: bundle, compatibleWith: nil)
        if let image = testImage {
            let imageData: Data = image.pngData() ?? Data()
            let imageSize: Int = imageData.count
            print("Actual size of image in KB:  \(Double(imageSize) / 1000.0)")
            base64Text = imageData.base64EncodedString()
        }
        return base64Text
    }
    
    func getTextForMultimediaRequest() -> String {
        let bizumText = "This is a bizum transfer 🟢"
        let utf8string = bizumText.data(using: .utf8)
        guard let base64EncodedString = utf8string?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
            logTestError(errorMessage: "ERROR ENCODING TEXT", function: #function)
            return ""
        }
        return base64EncodedString
    }
    
    // MARK: - Money Request Aux Methods
    private func getValidateMoneyRequestParams(receiverPhone: String) throws -> BizumValidateMoneyRequestInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        return BizumValidateMoneyRequestInputParams(checkPayment: bizumCheckPaymentDTO,
                                                    document: documentDTO,
                                                    dateTime: Date(),
                                                    concept: "Solicitud de dinero",
                                                    amount: "6.50",
                                                    receiverUserId: receiverPhone)
    }
    
    private func getMoneyRequestParams(receiverPhone: String) throws -> BizumMoneyRequestInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        guard let params = try getValidateMoneyRequestParams(receiverPhone: receiverPhone) else {
            return nil
        }
        guard let validateMoneyRequest = try bsanBizumManager?.validateMoneyRequest(params) else {
            return nil
        }
        guard let bizumValidateMoneyRequestDTO = try getResponseData(response: validateMoneyRequest) else {
            return nil
        }
        return BizumMoneyRequestInputParams(checkPayment: bizumCheckPaymentDTO,
                                            document: documentDTO,
                                            operationId: bizumValidateMoneyRequestDTO.operationId,
                                            dateTime: Date(),
                                            concept: "Money request",
                                            amount: "25.22",
                                            receiverUserId: receiverPhone)
    }
    
    private func getValidateMoneyRequestMultiParams(receiverPhones: [String]) throws -> BizumValidateMoneyRequestMultiInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        return BizumValidateMoneyRequestMultiInputParams(checkPayment: bizumCheckPaymentDTO,
                                                         document: documentDTO,
                                                         dateTime: Date(),
                                                         concept: "Solicitud de dinero multiple",
                                                         amount: "50.00",
                                                         receiverUserIds: receiverPhones)
    }
    
    private func getMoneyRequestMultiParams(receiversPhones: [String]) throws -> BizumMoneyRequestMultiInputParams? {
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        guard let params = try getValidateMoneyRequestMultiParams(receiverPhones: receiversPhones) else {
            return nil
        }
        guard let validateMoneyRequestMulti = try bsanBizumManager?.validateMoneyRequestMulti(params) else {
            return nil
        }
        guard let bizumValidateMoneyRequestMultiDTO = try getResponseData(response: validateMoneyRequestMulti) else {
            return nil
        }
        let actions: [BizumMoneyRequestMultiActionInputParam] = bizumValidateMoneyRequestMultiDTO.listValidationResponses.validationResponses.map {
            BizumMoneyRequestMultiActionInputParam(operationId: $0.operationId,
                                                   receiverUserId: $0.id,
                                                   action: $0.action)
        }
        return BizumMoneyRequestMultiInputParams(checkPayment: bizumCheckPaymentDTO,
                                                 document: documentDTO,
                                                 dateTime: Date(),
                                                 concept: "Money request multi",
                                                 amount: "80.20",
                                                 operationId: bizumValidateMoneyRequestMultiDTO.operationMultipleId,
                                                 actions: actions)
    }
}

private extension BizumTests {
    // If necessary, create a parameter in order to obtain others states and change the function name
    func getOperationsCancelled() throws -> BizumCancelNotRegisterInputParam? {
        //        "https://sanesp-pre.pru.bsch/payments/check-payment"
        let checkPayment = try bsanBizumManager?.checkPayment(defaultXPAN: "9724020250000001")
        if checkPayment == nil {
            return nil
        }
        guard let bizumCheckPaymentDTO = try getResponseData(response: checkPayment!) else {
            return nil
        }
        guard
            let documentResponse = try bsanBizumManager?.getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: "+34600937932")),
            let documentDTO = try getResponseData(response: documentResponse) else {
            return nil
        }
        let dateTo = Date()
        let dateFrom = dateTo.addingTimeInterval(-3600 * 24 * 31)
        
        let operationsResponse = try bsanBizumManager?.getOperations(BizumOperationsInputParams(checkPayment: bizumCheckPaymentDTO, page: 1, dateFrom: dateFrom, dateTo:dateTo, orderBy: "FECHA_ALTA", orderType: "DESC"))
        guard let operationsDTO = try getResponseData(response: operationsResponse!) else {
            return nil
        }
        let operationsCancelDTO = operationsDTO.operations.filter { $0.state == "PENDIENTEA" }
        guard let operationDTO = operationsCancelDTO.first else {
            return nil
        }
        return BizumCancelNotRegisterInputParam(checkPayment: bizumCheckPaymentDTO, document: documentDTO, operation: operationDTO, dateTime: dateTo)
    }
}
