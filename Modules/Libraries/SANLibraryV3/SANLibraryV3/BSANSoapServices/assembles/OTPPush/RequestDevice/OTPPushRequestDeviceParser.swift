import Foundation
import Fuzi

class OTPPushRequestDeviceParser: BSANParser<OTPPushRequestDeviceResponse, OTPPushRequestDeviceHandler> {
        
    override func setResponseData() {
        response.device = handler.device
    }
}

class OTPPushRequestDeviceHandler: BSANHandler {
    
    fileprivate var device: OTPPushDeviceDTO?
    
    override func parseResult(result: XMLElement) throws {
        guard
            let registerDate = DateFormats.safeDateInverseFull(result.firstChild(tag: "fechaRegistro")?.stringValue.trim()),
            let deviceLanguage = result.firstChild(tag: "idiomaDispositivo")?.stringValue.trim(),
            let deviceCode = result.firstChild(tag: "codDispositivo")?.stringValue.trim(),
            let deviceModel = result.firstChild(tag: "modeloDispositivo")?.stringValue.trim(),
            let deviceBrand = result.firstChild(tag: "fabricaDispositivo")?.stringValue.trim(),
            let appVersion = result.firstChild(tag: "versionApp")?.stringValue.trim(),
            let sdkVersion = result.firstChild(tag: "versionSDK")?.stringValue.trim(),
            let soVersion = result.firstChild(tag: "versionSO")?.stringValue.trim(),
            let platform = result.firstChild(tag: "plataformaDispositivo")?.stringValue.trim(),
            let modUser = result.firstChild(tag: "usuarioMod")?.stringValue.trim(),
            let modDate = DateFormats.safeDate(result.firstChild(tag: "fechaMod")?.stringValue.trim(), format: .YYYYMMDD)
        else {
            return
        }
        
        let deviceAlias = result.firstChild(tag: "aliasDispositivo")?.stringValue.trim()
        
        device = OTPPushDeviceDTO(
            registerDate: registerDate,
            deviceAlias: deviceAlias,
            deviceLanguage: deviceLanguage,
            deviceCode: deviceCode,
            deviceModel: deviceModel,
            deviceBrand: deviceBrand,
            appVersion: appVersion,
            sdkVersion: sdkVersion,
            soVersion: soVersion,
            platform: platform,
            modUser: modUser,
            modDate: modDate
        )
    }
}


