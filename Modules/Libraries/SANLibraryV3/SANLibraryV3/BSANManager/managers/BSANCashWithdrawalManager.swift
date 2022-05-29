import CoreFoundationLib
import Fuzi
import SANLegacyLibrary

public class BSANCashWithdrawalManagerImplementation: BSANBaseManager, BSANCashWithdrawalManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getCardDetailToken(cardDTO: CardDTO, cardTokenType: CardTokenType) throws -> BSANResponse<CardDetailTokenDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = GetCardDetailTokenRequest(
            BSANAssembleProvider.getCardsAssemble(try bsanDataProvider.isPB()),
            try bsanDataProvider.getEnvironment().urlBase,
            GetCardDetailTokenRequestParams(token: authCredentials.soapTokenCredential,
                                            version: bsanHeaderData.version,
                                            terminalId: bsanHeaderData.terminalID,
                                            userDataDTO: userDataDTO,
                                            language: bsanHeaderData.language,
                                            cardPAN: cardDTO.PAN ?? "",
                                            cardTokenType: cardTokenType))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            
            return BSANOkResponse(response.cardDetailTokenDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validatePIN(cardDTO: CardDTO, cardDetailTokenDTO: CardDetailTokenDTO) throws -> BSANResponse<SignatureWithTokenDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidatePinRequest(
            BSANAssembleProvider.getPINAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ValidatePinRequestParams(token: authCredentials.soapTokenCredential,
                                     cardToken: cardDetailTokenDTO.token ?? "",
                                     userDataDTO: userDataDTO,
                                     languageISO: bsanHeaderData.languageISO,
                                     dialectISO: bsanHeaderData.dialectISO,
                                     linkedCompany: bsanHeaderData.linkedCompany,
                                     PAN: cardDTO.formattedPAN ?? "",
                                     bankCode: cardDTO.contract?.bankCode ?? "",
                                     branchCode: cardDTO.contract?.branchCode ?? "",
                                     product: cardDTO.contract?.product ?? "",
                                     contractNumber: cardDTO.contract?.contractNumber ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.signatureWithTokenDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let extractedExpr = ValidateWithdrawalOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                               cardToken: signatureWithTokenDTO.magicPhrase ?? "",
                                                               userDataDTO: userDataDTO,
                                                               languageISO: bsanHeaderData.languageISO,
                                                               dialectISO: bsanHeaderData.dialectISO,
                                                               linkedCompany: bsanHeaderData.linkedCompany,
                                                               PAN: cardDTO.formattedPAN ?? "",
                                                               bankCode: cardDTO.contract?.bankCode ?? "",
                                                               branchCode: cardDTO.contract?.branchCode ?? "",
                                                               product: cardDTO.contract?.product ?? "",
                                                               contractNumber: cardDTO.contract?.contractNumber ?? "",
                                                               cardSignature: signatureWithTokenDTO.signatureDTO)
        let request = ValidateWithdrawalOTPRequest(
            BSANAssembleProvider.getCashWithdrawalAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            extractedExpr)
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidationDTO.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidationDTO)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidationDTO)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confirmOTP(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?, amount: AmountDTO, trusteerInfo: TrusteerInfoDTO?) throws -> BSANResponse<CashWithDrawalDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmWithdrawalOTPRequest(
            BSANAssembleProvider.getCashWithdrawalAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmWithdrawalOTPRequestParams(token: authCredentials.soapTokenCredential,
                                              cardToken: "",
                                              userDataDTO: userDataDTO,
                                              languageISO: bsanHeaderData.languageISO,
                                              dialectISO: bsanHeaderData.dialectISO,
                                              linkedCompany: bsanHeaderData.linkedCompany,
                                              PAN: cardDTO.formattedPAN ?? "",
                                              bankCode: cardDTO.contract?.bankCode ?? "",
                                              branchCode: cardDTO.contract?.branchCode ?? "",
                                              product: cardDTO.contract?.product ?? "",
                                              contractNumber: cardDTO.contract?.contractNumber ?? "",
                                              otpTicket: otpValidationDTO?.ticket ?? "",
                                              otpToken: otpValidationDTO?.magicPhrase ?? "",
                                              otpCode: otpCode ?? "",
                                              amount: amount,
                                              trusteerInfo: trusteerInfo))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            response.cashWithDrawalDTO.decryptedDataDTO = decryptInfo(encrypted: response.cashWithDrawalDTO.descListaActivadorClave ?? "", userDataDTO: userDataDTO, cardDTO: cardDTO)
            return BSANOkResponse(meta, response.cashWithDrawalDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getHistoricalWithdrawal(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<HistoricalWithdrawalDTO> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getCashWithdrawalAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = HistoricalCashWithdrawalRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            HistoricalCashWithdrawalRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  linkedCompany: bsanHeaderData.linkedCompany,
                                                  PAN: cardDTO.PAN ?? "",
                                                  bankCode: cardDTO.contract?.bankCode ?? "",
                                                  branchCode: cardDTO.contract?.branchCode ?? "",
                                                  product: cardDTO.contract?.product ?? "",
                                                  contractNumber: cardDTO.contract?.contractNumber ?? "",
                                                  cardSignature: signatureWithTokenDTO))
        
        let response: HistoricalCashWithdrawalResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            guard var dispensationList = response.historicalWithdrawalDTO.dispensationList else {
                return BSANOkResponse(meta, response.historicalWithdrawalDTO)
            }
            
            let decryptedDataList = decryptInfoList(encrypted: response.historicalWithdrawalDTO.descListaActivadorClave ?? "", userDataDTO: userDataDTO, cardDTO: cardDTO)
            if decryptedDataList.count > 0 {
                for i in 0...decryptedDataList.count-1 {
                    dispensationList[i].decryptedData = decryptedDataList[i]
                }
            }
            response.historicalWithdrawalDTO.dispensationList = dispensationList
            return BSANOkResponse(meta, response.historicalWithdrawalDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    private func decryptInfo(encrypted: String, userDataDTO: UserDataDTO, cardDTO: CardDTO) -> DecryptedDataDTO{
        var decryptedData = DecryptedDataDTO()
        var claveCifrado = "\(cardDTO.contract?.formattedValue ?? "")\(userDataDTO.clientPersonType ?? "")\(userDataDTO.clientPersonCode ?? "")\(userDataDTO.channelFrame ?? "")\(userDataDTO.contract?.formattedValue ?? "")"
        
        // The "cardDTO.contract?.formattedValue" value is different when we use debit card or
        // prepaid card but the mock response (that contains the info ciphered with the an specific key) used is the same
        // so we have to hardcode the "claveCifrado" to decrypt the ciphered info and show the QR code and
        // operation code of cash withdraw operation in both card types cases in resume operation screen
        if bsanDataProvider.isDemo() {
            claveCifrado = "004935685000000001F124520395RML004930243390349207"
        }
        
        while claveCifrado.count < 32 {
            claveCifrado += "0"
        }
        
        do {
            guard let clave = claveCifrado.substring(0, 32) else {
                return decryptedData
            }
            
            let descListaActivadorPlain = try DataCipher.decryptDESde(encrypted, clave)
            decryptedData.descListaActivadorPlain = descListaActivadorPlain
            
            do {
                let xmlDocument = try XMLDocument.init(string: descListaActivadorPlain, encoding: String.Encoding.utf8)
                if let item = xmlDocument.root?.firstChild(tag: "item") {
                    if let telefonoOTP = item.attr("telefonoOTP") {
                        decryptedData.telefonoOTP = telefonoOTP.trim()
                    }
                    
                    if let claveSC = item.attr("claveSC") {
                        decryptedData.claveSC = claveSC.trim()
                    }
                    if let codQR = item.attr("codQR") {
                        decryptedData.codQR = codQR.trim().hexStringToString
                    }
                }
            }
            catch let ee {
                print(ee.localizedDescription)
            }
        }
        catch let e {
            print(e.localizedDescription)
        }
        
        return decryptedData
    }
    
    private func decryptInfoList(encrypted: String, userDataDTO: UserDataDTO, cardDTO: CardDTO) -> [DecryptedDataDTO]{
        var decryptedData = [DecryptedDataDTO]()
        var claveCifrado = "\(cardDTO.contract?.formattedValue ?? "")\(userDataDTO.clientPersonType ?? "")\(userDataDTO.clientPersonCode ?? "")\(userDataDTO.channelFrame ?? "")\(userDataDTO.contract?.formattedValue ?? "")"
        
        while claveCifrado.count < 32 {
            claveCifrado += "0"
        }
        
        do {
            guard let clave = claveCifrado.substring(0, 32) else {
                return decryptedData
            }
            
            let descListaActivadorPlain = try DataCipher.decryptDESde(encrypted, clave)

            do {
                let xmlDocument = try XMLDocument.init(string: descListaActivadorPlain, encoding: String.Encoding.utf8)
                
                if let documentChildren = xmlDocument.root?.children(tag: "item") {
                    if documentChildren.count > 0 {
                        for item in documentChildren {
                            var newDecryptedData = DecryptedDataDTO()
                            newDecryptedData.descListaActivadorPlain = descListaActivadorPlain
                            if let telefonoOTP = item.attr("telefonoOTP") {
                                newDecryptedData.telefonoOTP = telefonoOTP.trim()
                            }
                            
                            if let claveSC = item.attr("claveSC") {
                                newDecryptedData.claveSC = claveSC.trim()
                            }
                            if let codQR = item.attr("codQR") {
                                newDecryptedData.codQR = codQR.trim().hexStringToString
                            }
                            
                            decryptedData.append(newDecryptedData)
                        }
                    }
                }
            }
            catch let ee {
                print(ee.localizedDescription)
            }
        }
        catch let e {
            print(e.localizedDescription)
        }
        
        return decryptedData
    }
}
