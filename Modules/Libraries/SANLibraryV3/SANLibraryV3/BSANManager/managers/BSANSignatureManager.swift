import SANLegacyLibrary

public class BSANSignatureManagerImplementation: BSANBaseManager, BSANSignatureManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    public func getCMCSignature() throws -> BSANResponse<SignStatusInfo> {
        
        if let signStatusInfo = try bsanDataProvider.get(\.signStatusInfo) {
            return BSANOkResponse(signStatusInfo)
        }
        
        return  BSANErrorResponse(nil)
    }
    
    public func loadCMCSignature() throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = CMCSignatureRequest(
            BSANAssembleProvider.getCMCSignatureAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            CMCSignatureRequestParams.createParams(authCredentials.soapTokenCredential)
                .setUserDataDTO(userDataDTO)
                .setLanguageISO(bsanHeaderData.languageISO)
                .setDialectISO(bsanHeaderData.dialectISO)
                .setLinkedCompany(bsanHeaderData.linkedCompany)
        )
        
        let response = try sanSoapServices.executeCall(request)
        
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            bsanDataProvider.storeCMCSignature(response: response)
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return  BSANErrorResponse(meta)
    }
    
    public func validateSignatureActivation() throws -> BSANResponse<SignatureWithTokenDTO> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ValidateSignatureActivationRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ValidateSignatureActivationRequestParams(token: authCredentials.soapTokenCredential,
                                                     userDataDTO: userDataDTO,
                                                     languageISO: bsanHeaderData.languageISO,
                                                     dialectISO: bsanHeaderData.dialectISO,
                                                     linkedCompany: bsanHeaderData.linkedCompany))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(response.signatureWithTokenDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func validateOTPOperability(newOperabilityInd: String, signatureWithTokenDTO: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = OTPValidateOperabilityRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            OTPValidateOperabilityRequestParams(token: authCredentials.soapTokenCredential,
                                                     userDataDTO: userDataDTO,
                                                     languageISO: bsanHeaderData.languageISO,
                                                     dialectISO: bsanHeaderData.dialectISO,
                                                     linkedCompany: bsanHeaderData.linkedCompany,
                                                     newOperabilityInd: newOperabilityInd,
                                                     signatureWithTokenDTO: signatureWithTokenDTO))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        
        if response.otpValidation.otpExcepted || meta.code == BSANSoapResponse.RESULT_OTP_EXCEPTED_USER {
            meta.code = BSANSoapResponse.RESULT_OTP_EXCEPTED_USER
            return BSANOkResponse(meta, response.otpValidation)
            
        } else {
            if meta.isOK() {
                BSANLogger.i(logTag, "Meta OK")
                return BSANOkResponse(meta, response.otpValidation)
            }
            return BSANErrorResponse(meta)
        }
    }
    
    public func confimOperabilityChange(newOperabilityInd: String, otpValidationDTO: OTPValidationDTO?, otpCode: String?) throws -> BSANResponse<Void> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmOperabilityChangeRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmOperabilityChangeRequestParams(token: authCredentials.soapTokenCredential,
                                                  userDataDTO: userDataDTO,
                                                  languageISO: bsanHeaderData.languageISO,
                                                  dialectISO: bsanHeaderData.dialectISO,
                                                  otpToken: otpValidationDTO?.magicPhrase ?? "",
                                                  otpTicket: otpValidationDTO?.ticket ?? "",
                                                  otpCode: otpCode ?? "",
                                                  linkedCompany: bsanHeaderData.linkedCompany,
                                                  newOperabilityInd: newOperabilityInd)
        )
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");

            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmSignatureActivation(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConfirmSignatureActivationRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmSignatureActivationRequestParams(token: authCredentials.soapTokenCredential,
                                                    userDataDTO: userDataDTO,
                                                    languageISO: bsanHeaderData.languageISO,
                                                    dialectISO: bsanHeaderData.dialectISO,
                                                    linkedCompany: bsanHeaderData.linkedCompany,
                                                    signatureDTO: signatureDTO,
                                                    newSignatureCiphered: CipherKeys(userDataDTO: userDataDTO).getCipherKeys(keyNoCipher: newSignature) ?? ""))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func confirmSignatureChange(newSignature: String, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let cipherKeys = CipherKeys(userDataDTO: userDataDTO)
        
        let request = ConfirmSignatureChangeRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ConfirmSignatureChangeRequestParams(token: authCredentials.soapTokenCredential,
                                                signatureDTO: signatureDTO,
                                                newSignatureCiphered: cipherKeys.getCipherKeys(keyNoCipher: newSignature) ?? "",
                                                userDataDTO: userDataDTO,
                                                languageISO: bsanHeaderData.languageISO,
                                                dialectISO: bsanHeaderData.dialectISO,
                                                linkedCompany: bsanHeaderData.linkedCompany))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func changePassword(oldPassword: String, newPassword: String) throws -> BSANResponse<Void> {
        
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let cipherKeys = CipherKeys(userDataDTO: userDataDTO)
        
        let request = ChangePasswordRequest(
            BSANAssembleProvider.getSignatureAssemble(), // same assemble for all
            try bsanDataProvider.getEnvironment().urlBase,
            ChangePasswordRequestParams(token: authCredentials.soapTokenCredential,
                                        oldPasswordCiphered: cipherKeys.getCipherKeys(keyNoCipher: oldPassword) ?? "",
                                        newPasswordCiphered: cipherKeys.getCipherKeys(keyNoCipher: newPassword) ?? "",
                                        userDataDTO: userDataDTO,
                                        languageISO: bsanHeaderData.languageISO,
                                        dialectISO: bsanHeaderData.dialectISO,
                                        linkedCompany: bsanHeaderData.linkedCompany))
        
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK");
            return BSANOkResponse(meta)
        }
        return BSANErrorResponse(meta)
    }
    
    public func consultPensionSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getPensionOperationsAssemble())
    }
    
    public func consultSendMoneySignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getSendMoneyAssemble())
    }
    
    public func consultCardsPayOffSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getCardsPayOffAssemble())
    }
    
    public func consultCashWithdrawalSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getCashWithdrawalAssemble())
    }
    
    public func consultChangeSignSignaturePositions() throws -> BSANResponse<SCARepresentable> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getSignatureAssemble())
    }
    
    public func consultScheduledSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getScheduledTransfersAssemble())
    }
    
    public func consultCardLimitManagementPositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getChangeLimitCardAssemble())
    }
    
    public func requestOTPPushRegisterDevicePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getOTPPushAssemble(), languageDefault: true)
    }
    
    public func consultBillAndTaxesSignaturePositions() throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getBillTaxesAssemble())
    }
    
    public func requestApplePaySignaturePositions( )throws -> BSANResponse<SignatureWithTokenDTO> {
        return try consultSignaturePositions(assemble: BSANAssembleProvider.getApplePayAssemble())
    }
    
    private func consultSignaturePositions(assemble: BSANAssemble, languageDefault: Bool? = false) throws -> BSANResponse<SignatureWithTokenDTO> {
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let userDataDTO = try bsanDataProvider.getUserData()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        
        let request = ConsultSignaturePositionsRequest(
            BSANAssembleProvider.getSendMoneyAssemble(),
            try bsanDataProvider.getEnvironment().urlBase,
            ConsultSignaturePositionsRequestParams(token: authCredentials.soapTokenCredential,
                                                   userDataDTO: userDataDTO,
                                                   languageISO: (languageDefault ?? false) ? BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES : bsanHeaderData.languageISO,
                                                   dialectISO: (languageDefault ?? false) ? BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES : bsanHeaderData.dialectISO,
                                                   linkedCompany: bsanHeaderData.linkedCompany,
                                                   acronymWsCaller: assemble.acronym))
        
        let response = try sanSoapServices.executeCall(request);
        
        let meta = try Meta.createMeta(request, response);
        if (meta.isOK()) {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(response.signatureWithTokenDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    private func consultSignaturePositions(assemble: BSANAssemble) throws -> BSANResponse<SCARepresentable> {
        let response = try consultSignaturePositions(assemble: assemble, languageDefault: false)
        if response.isSuccess(), let signature = try response.getResponseData() {
            return BSANOkResponse(signature)
        }
        return BSANErrorResponse(nil)
    }
}
