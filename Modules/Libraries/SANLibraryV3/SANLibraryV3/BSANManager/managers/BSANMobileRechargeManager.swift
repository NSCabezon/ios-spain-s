import SANLegacyLibrary

public class BSANMobileRechargeManagerImplementation: BSANBaseManager, BSANMobileRechargeManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    /**
     * Servicio para testear
     */
    public func getMobileOperators(card: CardDTO) throws -> BSANResponse<MobileOperatorListDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMobileRechargeAssemble(try bsanDataProvider.isPB())
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = bsanDataProvider.getBsanHeaderDataESforMobileRecharge()
        
        let request = GetMobileOperatorsRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            GetMobileOperatorsRequestParams(token: authCredentials.soapTokenCredential,
                                            userDataDTO: userDataDTO,
                                            languageISO: bsanHeaderData.languageISO,
                                            dialectISO: bsanHeaderData.dialectISO,
                                            linkedCompany: bsanHeaderData.linkedCompany,
                                            cardContract: card.contract ?? ContractDTO()))
        
        let response: GetMobileOperatorsResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(mobileOperatorDTO: response.mobileOperatorListDTO.mobileOperatorList?[0])
            return BSANOkResponse(meta, response.mobileOperatorListDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    /**
     * Servicio para testear
     */
    public func validateMobileRecharge(card: CardDTO) throws -> BSANResponse<ValidateMobileRechargeDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMobileRechargeAssemble(try bsanDataProvider.isPB())
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = bsanDataProvider.getBsanHeaderDataESforMobileRecharge()
        
        let request = ValidateMobileRechargeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateMobileRechargeRequestParams(token: authCredentials.soapTokenCredential,
                                                userDataDTO: userDataDTO,
                                                languageISO: bsanHeaderData.languageISO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                linkedCompany: bsanHeaderData.linkedCompany,
                                                cardContract: card.contract ?? ContractDTO(),
                                                cardPan: card.PAN ?? ""))
        
        let response: ValidateMobileRechargeResponse = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(validateMobileRechargeDTO: response.validateMobileRechargeDTO)
            return BSANOkResponse(meta, response.validateMobileRechargeDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    /**
     * Servicio para testear
     */
    public func validateMobileRechargeOTP(card: CardDTO, signature: SignatureWithTokenDTO, mobile: String, amount: AmountDTO, mobileOperatorDTO: MobileOperatorDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMobileRechargeAssemble(try bsanDataProvider.isPB())
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = bsanDataProvider.getBsanHeaderDataESforMobileRecharge()
        
        let request = ValidateMobileRechargeOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateMobileRechargeOTPRequestParams(token: authCredentials.soapTokenCredential,
                                                   userDataDTO: userDataDTO,
                                                   languageISO: bsanHeaderData.languageISO,
                                                   dialectISO: bsanHeaderData.dialectISO,
                                                   linkedCompany: bsanHeaderData.linkedCompany,
                                                   cardContract: card.contract ?? ContractDTO(),
                                                   signature: signature,
                                                   mobile: mobile,
                                                   amount: amount,
                                                   mobileOperatorCode: mobileOperatorDTO.code ?? ""))
        
        let response: ValidateMobileRechargeOTPResponse = try sanSoapServices.executeCall(request)
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
    
    /**
     * Servicio para testear
     */
    public func confirmMobileRecharge(card: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
       
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getMobileRechargeAssemble(try bsanDataProvider.isPB())
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = bsanDataProvider.getBsanHeaderDataESforMobileRecharge()
        
        let request = ConfirmMobileRechargeRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmMobileRechargeRequestParams(token: authCredentials.soapTokenCredential,
                                               userDataDTO: userDataDTO,
                                               languageISO: bsanHeaderData.languageISO,
                                               dialectISO: bsanHeaderData.dialectISO,
                                               linkedCompany: bsanHeaderData.linkedCompany,
                                               cardContract: card.contract ?? ContractDTO(),
                                               otpTicket: otpValidationDTO?.ticket ?? "",
                                               otpToken: otpValidationDTO?.magicPhrase ?? "",
                                               otpCode: otpCode ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
}
