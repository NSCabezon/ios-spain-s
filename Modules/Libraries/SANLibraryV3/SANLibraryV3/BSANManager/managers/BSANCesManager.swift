import SANLegacyLibrary

public class BSANCesManagerImplementation: BSANBaseManager, BSANCesManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func validateOTP(cardDTO: CardDTO, signatureWithTokenDTO: SignatureWithTokenDTO, phone: String) throws -> BSANResponse<OTPValidationDTO> {
       
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getCardsCesAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateCesOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ValidateCesOTPRequestParams(token: authCredentials.soapTokenCredential,
                                        userDataDTO: userDataDTO,
                                        languageISO: bsanHeaderData.languageISO,
                                        dialectISO: bsanHeaderData.dialectISO,
                                        linkedCompany: bsanHeaderData.linkedCompany,
                                        PAN: cardDTO.PAN ?? "",
                                        phone: phone,
                                        cardSignature: signatureWithTokenDTO.signatureDTO,
                                        contractDTO: cardDTO.contract))
        
        let response: ValidateCesOTPResponse = try sanSoapServices.executeCall(request)
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
    
    public func confirmOTP(cardDTO: CardDTO, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        
        let bsanAssemble: BSANAssemble = BSANAssembleProvider.getCardsCesAssemble()
        
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmCesOTPRequest(
            bsanAssemble,
            bsanEnvironment.urlBase,
            ConfirmCesOTPRequestParams(token: authCredentials.soapTokenCredential,
                                       userDataDTO: userDataDTO,
                                       languageISO: bsanHeaderData.languageISO,
                                       dialectISO: bsanHeaderData.dialectISO,
                                       linkedCompany: bsanHeaderData.linkedCompany,
                                       otpTicket: otpValidationDTO?.ticket ?? "",
                                       otpToken: otpValidationDTO?.magicPhrase ?? "",
                                       otpCode: otpCode ?? "",
                                       contractDTO: cardDTO.contract))
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
}
