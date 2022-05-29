import Foundation
import SANLegacyLibrary

public class BSANScaManagerImplementation: BSANBaseManager, BSANScaManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }

    public func checkSca() throws -> BSANResponse<CheckScaDTO> {
        var scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        guard !scaInfo.scaCheckFail else {
            return BSANErrorResponse<CheckScaDTO>(Meta.createKO())
        }
        if let checkScaDTO: CheckScaDTO = scaInfo.sca {
            return BSANOkResponse(checkScaDTO)
        } else {
            let response: BSANResponse<CheckScaDTO> = try loadCheckSca()
            if !response.isSuccess() {
                scaInfo.scaCheckFail = true
                bsanDataProvider.updateGlobalSessionData(scaInfo: scaInfo)
            }
            return response
        }
    }
    
    public func loadCheckSca() throws -> BSANResponse<CheckScaDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO: UserDataDTO = try bsanDataProvider.getUserData()
        let authCredentials: AuthCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData: BSANHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request: CheckScaRequest = CheckScaRequest(
            BSANAssembleProvider.getScaAssemble(),
            bsanEnvironment.urlBase,
            CheckScaRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO
            )
        )
        let response: CheckScaResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let checkScaDTO: CheckScaDTO = response.checkScaDTO else {
            return BSANErrorResponse<CheckScaDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        var scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        scaInfo.sca = checkScaDTO
        bsanDataProvider.updateGlobalSessionData(scaInfo: scaInfo)
        return BSANOkResponse(meta, checkScaDTO)
    }
    
    public func isScaOtpOkForAccounts() throws -> BSANResponse<Bool> {
        let scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        return BSANOkResponse(scaInfo.scaAccountsOtpOk)
    }
    
    public func saveScaOtpLoginTemporaryBlock() throws {
        var scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        scaInfo.sca?.loginIndicator = ScaLoginState.temporaryLock
    }
    
    public func saveScaOtpAccountTemporaryBlock() throws {
        var scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        scaInfo.sca?.accountIndicator = ScaAccountState.temporaryLock
    }
    
    public func isScaOtpAskedForLogin() throws -> BSANResponse<Bool> {
        let scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
        return BSANOkResponse(scaInfo.scaLoginOtpOk)
    }
    
    @available(iOS, deprecated: 6.0.25, message: "new method validateSca(forwardIndicator: Bool, foceSMS: Bool, operativeIndicator: ScaOperativeIndicatorDTO)")
    public func validateSca(forwardIndicator: Bool, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ValidateScaDTO> {
        return try validateSca(forwardIndicator: forwardIndicator, foceSMS: false, operativeIndicator: operativeIndicator)
    }
    
    public func validateSca(forwardIndicator: Bool, foceSMS: Bool, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ValidateScaDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO: UserDataDTO = try bsanDataProvider.getUserData()
        let authCredentials: AuthCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData: BSANHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request: ValidateScaRequest = ValidateScaRequest(
            BSANAssembleProvider.getScaAssemble(),
            bsanEnvironment.urlBase,
            ValidateScaRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                forwardIndicator: forwardIndicator,
                forceSMS: foceSMS,
                operativeIndicator: operativeIndicator,
                linkedCompany: bsanHeaderData.linkedCompany
            )
        )
        let response: ValidateScaResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let validateScaDTO: ValidateScaDTO = response.validateScaDTO else {
            return BSANErrorResponse<ValidateScaDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta, validateScaDTO)
    }
    
    public func confirmSca(tokenOTP: String?, ticketOTP: String?, codeOTP: String, operativeIndicator: ScaOperativeIndicatorDTO) throws -> BSANResponse<ConfirmScaDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO: UserDataDTO = try bsanDataProvider.getUserData()
        let authCredentials: AuthCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData: BSANHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request: ConfirmScaRequest = ConfirmScaRequest(
            BSANAssembleProvider.getScaAssemble(),
            bsanEnvironment.urlBase,
            ConfirmScaRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                tokenOTP: tokenOTP,
                ticketOTP: ticketOTP,
                codeOTP: codeOTP,
                operativeIndicator: operativeIndicator
            )
        )
        let response: ConfirmScaResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let confirmScaDTO: ConfirmScaDTO = response.confirmScaDTO else {
            return BSANErrorResponse<ConfirmScaDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        if confirmScaDTO.otpValIndicator == "0" {
            var scaInfo: ScaInfo = try bsanDataProvider.getGlobalSessionData().scaInfo
            switch operativeIndicator {
            case .login:
                scaInfo.scaLoginOtpOk = true
            case .accounts:
                scaInfo.scaAccountsOtpOk = true
            }
            bsanDataProvider.updateGlobalSessionData(scaInfo: scaInfo)
        }
        return BSANOkResponse(meta, confirmScaDTO)
    }
}

