import Foundation
import SANLegacyLibrary

public class BSANOTPPushManagerImplementation: BSANBaseManager, BSANOTPPushManager {
    
    var sanSoapServices: SanSoapServices
    
    public init(bsanDataProvider: BSANDataProvider, sanSoapServices: SanSoapServices) {
        self.sanSoapServices = sanSoapServices
        super.init(bsanDataProvider: bsanDataProvider)
    }
    
    /// Method that call `consultaDispositivoLa` service
    /// - Parameter appId: The twinpush AppID
    public func requestDevice() throws -> BSANResponse<OTPPushDeviceDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = OTPPushRequestDeviceRequest(
            BSANAssembleProvider.getOTPPushAssemble(),
            bsanEnvironment.urlBase,
            OTPPushRequestDeviceRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO
            )
        )
        let response: OTPPushRequestDeviceResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        guard meta.isOK(), let device = response.device else {
            return BSANErrorResponse<OTPPushDeviceDTO>(meta)
        }
        BSANLogger.i(logTag, "Meta OK")
        return BSANOkResponse(meta, device)
    }
    
    /// Method that call `validaAltaDispositivoLa` service
    public func validateRegisterDevice(signature: SignatureWithTokenDTO) throws -> BSANResponse<OTPValidationDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = OTPPushValidateRegisterDeviceRequest(
            BSANAssembleProvider.getOTPPushAssemble(),
            bsanEnvironment.urlBase,
            OTPPushValidateRegisterDeviceRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                signature: signature
            )
        )
        let response: OTPPushValidateRegisterDeviceResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK(), let data = response.otpValidation {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, data)
        }
        return BSANErrorResponse(meta)
    }
    
    /// Method that call `altaDispositivoHistoricoLa` service
    public func registerDevice(otpValidation: OTPValidationDTO, otpCode: String, data: OTPPushConfirmRegisterDeviceInputDTO) throws -> BSANResponse<ConfirmOTPPushDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = OTPPushConfirmRegisterDeviceRequest(
            BSANAssembleProvider.getOTPPushAssemble(),
            bsanEnvironment.urlBase,
            OTPPushConfirmRegisterDeviceRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                deviceUDID: data.deviceUDID,
                deviceToken: data.deviceToken,
                deviceAlias: data.deviceAlias,
                deviceLanguage: data.deviceLanguage,
                deviceCode: data.deviceCode,
                deviceModel: data.deviceModel,
                deviceBrand: data.deviceBrand,
                appVersion: data.appVersion,
                sdkVersion: data.sdkVersion,
                soVersion: data.soVersion,
                platform: data.platform,
                modUser: data.modUser,
                operativeDes: data.operativeDes,
                stepToken: otpValidation.magicPhrase ?? "",
                ticket: otpValidation.ticket ?? "",
                otpCode: otpCode
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(codeOTPPush: .rightRegisteredDevice)
            return BSANOkResponse(meta, response.confirmOTPPushDTO)
        }
        return BSANErrorResponse(meta)
    }
    
    public func updateTokenPush(currentToken: String, newToken: String) throws -> BSANResponse<Void> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = UpdateTokenPushRequest(
            BSANAssembleProvider.getOTPPushAssemble(),
            bsanEnvironment.urlBase,
            UpdateTokenRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                language: bsanHeaderData.languageISO,
                dialect: bsanHeaderData.dialectISO,
                currentToken: currentToken,
                newToken: newToken
            )
        )
        let response = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            return BSANOkResponse(meta, nil)
        }
        return BSANErrorResponse(meta)
    }
    
    /// Method that call `validaDispositivoLa` service
    public func validateDevice(deviceToken: String) throws -> BSANResponse<OTPPushValidateDeviceDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try bsanDataProvider.getEnvironment()
        let userDataDTO = try bsanDataProvider.getUserData()
        let authCredentials = try bsanDataProvider.getAuthCredentials()
        let bsanHeaderData = try bsanDataProvider.getBsanHeaderData()
        let request = OTPPushValidateDeviceRequest(
            BSANAssembleProvider.getOTPPushAssemble(),
            bsanEnvironment.urlBase,
            OTPPushValidateDeviceRequestParams(
                token: authCredentials.soapTokenCredential,
                userDataDTO: userDataDTO,
                languageISO: bsanHeaderData.languageISO,
                dialectISO: bsanHeaderData.dialectISO,
                deviceToken: deviceToken
            )
        )
        let response: OTPPushValidateDeviceResponse = try sanSoapServices.executeCall(request)
        let meta = try Meta.createMeta(request, response)
        if meta.isOK() {
            BSANLogger.i(logTag, "Meta OK")
            bsanDataProvider.store(codeOTPPush: response.otpPushValidateDevice?.returnCode)
            return BSANOkResponse(meta, response.otpPushValidateDevice)
        }
        return BSANErrorResponse(meta)
    }
    
    public func getValidatedDeviceState() throws -> BSANResponse<ReturnCodeOTPPush> {
        guard let codeOTPPush = try self.bsanDataProvider.get(\.codeOTPPush) else {
            return BSANErrorResponse(nil)
        }
        return BSANOkResponse(Meta.createOk(), codeOTPPush)
    }
}
