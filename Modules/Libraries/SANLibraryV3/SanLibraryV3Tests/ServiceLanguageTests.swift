import XCTest
@testable import SanLibraryV3

class ServiceLanguageTests: XCTestCase {

    let bsanAssemble: BSANAssemble = BSANAssemble("testFacade", "testEndpoint")
    let bsanEnvironment: BSANEnvironmentDTO = BSANEnvironmentDTOMock()
    let userDataDTO: UserDataDTO = UserDataDTO()
    let authCredentials: AuthCredentials = AuthCredentials(soapTokenCredential: "TestSoap", apiTokenCredential: "TestAPI", apiTokenType: "TestType")
    let bsanHeaderData: BSANHeaderData = BSANHeaderData.newInstanceForSanES(version: "Test")
    let spanishLanguage = "es-ES"
    let specialLanguage = " io"
    
    func testAccountTransactionsRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createAccountTransactionRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "datosCabecera", childKeys: ["idioma"])
        XCTAssertEqual(languageResult.first?["idioma"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["listaMovCuentas_LIP"])
        
        let languageResultChanged = parseMessage(sut.message, key: "datosCabecera", childKeys: ["idioma"])
        XCTAssertEqual(languageResultChanged.first?["idioma"], specialLanguage)
    }
    
    func testAccountTransactionsRequestWithDate() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createAccountTransactionRequestWithDate()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "datosCabecera", childKeys: ["idioma"])
        XCTAssertEqual(languageResult.first?["idioma"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["listaMovCuentasFechas_LIP"])
        
        let languageResultChanged = parseMessage(sut.message, key: "datosCabecera", childKeys: ["idioma"])
        XCTAssertEqual(languageResultChanged.first?["idioma"], specialLanguage)
    }
    
    func testConfirmWithdrawalOTPRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createConfirmWithdrawalOTPRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["confirmarEmisionSacarDinero_LA"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    
    func testValidateOTPPrepaidCardRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidateOTPPrepaidCardRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validarCargaDescargaPrepagoOTP_LA"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    func testValidateCesOTPRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidateCesOTPRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idiomaCorporativo", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validaAltaTarjetaCesOtpLa"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idiomaCorporativo", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    func testValidateCVVOTPRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidateCVVOTPRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validarConsultaDeCVV2OTP_LA"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    
    func testValidateMobileRechargeOTPRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidateMobileRechargeOTPRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validaRecargaMovilOtpLa"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    
    func testValidateModifyDeferredTransferRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidateModifyDeferredTransferRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validarModificarDiferidaLa"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
    func testValidatePINOTPRequest() {
        let serviceNameLanguage = ServiceNameLanguage()
        BSANBaseManager.serviceNameLanguage = serviceNameLanguage
        
        let sut = createValidatePINOTPRequest()
        
        serviceNameLanguage.setSpecialLanguageServiceNames([])
        
        let languageResult = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResult.first?["IDIOMA_ISO"], spanishLanguage)
        
        serviceNameLanguage.setSpecialLanguageServiceNames(["validarConsultaDePINOTP_LA"])
        
        let languageResultChanged = parseMessage(sut.message, key: "idioma", childKeys: ["IDIOMA_ISO"])
        XCTAssertEqual(languageResultChanged.first?["IDIOMA_ISO"], specialLanguage)
    }
    
}

private extension ServiceLanguageTests {
    
    func parseMessage(_ message: String, key: String, childKeys: [String]) -> [[String: String]] {
        let data = message.data(using: .utf8)!
        let xml = XMLParser(data: data)
        let delegate = TestXML(recordKey: key, childKeys: childKeys)
        xml.delegate = delegate
        xml.parse()
        
        return delegate.results
    }
    
    func createAccountTransactionRequest() -> AccountTransactionsRequest {
        let parameters = AccountTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                                          userDataDTO: userDataDTO,
                                                          bankCode: "test",
                                                          branchCode: "test",
                                                          product: "test",
                                                          contractNumber: "test",
                                                          terminalId: bsanHeaderData.terminalID,
                                                          version: bsanHeaderData.version,
                                                          language: bsanHeaderData.language,
                                                          pagination: nil,
                                                          dateFilter: nil,
                                                          filter: nil)
        
        return AccountTransactionsRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    func createAccountTransactionRequestWithDate() -> AccountTransactionsRequest {
        let parameters = AccountTransactionsRequestParams(token: authCredentials.soapTokenCredential,
                                                          userDataDTO: userDataDTO,
                                                          bankCode: "test",
                                                          branchCode: "test",
                                                          product: "test",
                                                          contractNumber: "test",
                                                          terminalId: bsanHeaderData.terminalID,
                                                          version: bsanHeaderData.version,
                                                          language: bsanHeaderData.language,
                                                          pagination: nil,
                                                          dateFilter: DateFilter(from: nil, to: nil),
                                                          filter: nil)
        
        return AccountTransactionsRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    func createConfirmWithdrawalOTPRequest() -> ConfirmWithdrawalOTPRequest {
        let parameters = ConfirmWithdrawalOTPRequestParams(token: "TestToken", cardToken: "Test",
                                                           userDataDTO: userDataDTO,
                                                           languageISO: bsanHeaderData.language,
                                                           dialectISO: "test",
                                                           linkedCompany: "test",
                                                           PAN: "test",
                                                           bankCode: "Test",
                                                           branchCode: "Test",
                                                           product: "Test",
                                                           contractNumber: "1234",
                                                           otpTicket: "Test",
                                                           otpToken: "Test",
                                                           otpCode: "Test",
                                                           amount: AmountDTO(), trusteerInfo: nil)
        
        return ConfirmWithdrawalOTPRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }

    func createValidateOTPPrepaidCardRequest() -> ValidateOTPPrepaidCardRequest {
        let parameters = ValidateOTPPrepaidCardRequestParams(token: "TestToken",
                                                             userDataDTO: userDataDTO,
                                                             languageISO: bsanHeaderData.language,
                                                             dialectISO: "test",
                                                             linkedCompany: "test",
                                                             cardDTO: CardDTO(),
                                                             signatureDTO: SignatureDTO(length: 8, positions: [1,2]),
                                                             validateLoadPrepaidCardDTO: ValidateLoadPrepaidCardDTO())
        return ValidateOTPPrepaidCardRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    func createValidateCesOTPRequest() -> ValidateCesOTPRequest {
        let parameters = ValidateCesOTPRequestParams(token: "TestToken",
                                                     userDataDTO: userDataDTO,
                                                     languageISO: bsanHeaderData.language,
                                                     dialectISO: "test",
                                                     linkedCompany: "test",
                                                     PAN: "1234567899",
                                                     phone: "66666666",
                                                     cardSignature: SignatureDTO(length: 8, positions: [1,2,3]),
                                                     contractDTO: nil)
        
        return ValidateCesOTPRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    func createValidateCVVOTPRequest() -> ValidateCVVOTPRequest {
        let parameters = ValidateCVVOTPRequestParams(token: "TestToken", cardDetailToken: "tokendetail",
                                                     userDataDTO: userDataDTO,
                                                     languageISO: bsanHeaderData.language,
                                                     dialectISO: "test",
                                                     linkedCompany: "test",
                                                     PAN: "1234567899",
                                                     bankCode: "bankCode", branchCode: "branchCode", product: "product", contractNumber: "testcontract",
                                                     cardSignature: SignatureDTO(length: 8, positions: [1,2,3]))
        
        return ValidateCVVOTPRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    
    func createValidateMobileRechargeOTPRequest() -> ValidateMobileRechargeOTPRequest {
        let parameters = ValidateMobileRechargeOTPRequestParams(token: "TestToken",
                                                                userDataDTO: userDataDTO,
                                                                languageISO: bsanHeaderData.language,
                                                                dialectISO: "test",
                                                                linkedCompany: "test",
                                                                cardContract: ContractDTO(bankCode: nil, branchCode: nil, product: nil, contractNumber: nil), signature: SignatureWithTokenDTO(), mobile: "product", amount: AmountDTO(),
                                                                mobileOperatorCode: "code")
        
        return ValidateMobileRechargeOTPRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    
    func createValidateModifyDeferredTransferRequest() -> ValidateModifyDeferredTransferRequest {
        let parameters = ValidateModifyDeferredTransferRequestParams(token: "TestToken",
                                                                     userDataDTO: userDataDTO,
                                                                     dialectISO: "test",
                                                                     languageISO: bsanHeaderData.language,
                                                                     signatureDTO: SignatureDTO(length: 8, positions: [1]),
                                                                     dataToken: "dataToken",
                                                                     orderingCurrency: "EUR",
                                                                     originIban: IBANDTO(ibanString: "1234546789"),
                                                                     beneficiaryIban: IBANDTO(ibanString: "2222222222222"),
                                                                     actingBeneficiary: InstructionStatusDTO(),
                                                                     nextExecutionDate: nil,
                                                                     amount: AmountDTO(),
                                                                     concept: "concept",
                                                                     indicatorResidence: true,
                                                                     operationType: InstructionStatusDTO(),
                                                                     sepaType: "sepa type",
                                                                     actingNumber: "12345",
                                                                     indOperationType: "operation")

        return ValidateModifyDeferredTransferRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
    func createValidatePINOTPRequest() -> ValidatePINOTPRequest {
        let parameters = ValidatePINOTPRequestParams(token: "TestToken",
                                                     cardToken: "tokendetail",
                                                     userDataDTO: userDataDTO,
                                                     languageISO: bsanHeaderData.language,
                                                     dialectISO: "test",
                                                     linkedCompany: "test",
                                                     PAN: "1234567899",
                                                     bankCode: "bankCode", branchCode: "branchCode", product: "product", contractNumber: "testcontract",
                                                     cardSignature: SignatureDTO(length: 8, positions: [1,2,3]))
        
        return ValidatePINOTPRequest(bsanAssemble, bsanEnvironment.urlBase, parameters)
    }
    
}
