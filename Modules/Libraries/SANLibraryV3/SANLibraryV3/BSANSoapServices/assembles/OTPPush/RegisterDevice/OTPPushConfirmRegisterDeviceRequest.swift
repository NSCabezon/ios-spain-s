//

import Foundation

class OTPPushConfirmRegisterDeviceRequest: BSANSoapRequest<OTPPushConfirmRegisterDeviceRequestParams, OTPPushConfirmRegisterDeviceHandler, OTPPushConfirmRegisterDeviceResponse, OTPPushConfirmRegisterDeviceParser> {
    
    static public var serviceName = "altaDispositivoHistoricoLa"
    
    public override var serviceName: String {
        return OTPPushConfirmRegisterDeviceRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SUPOTE/Altaote_la/F_supote_altaote_la/ACSUPOTEAltaOTE/v1"
    }
    
    override var message: String {
        var aliasDevice: String = ""
        if let alias = params.deviceAlias {
            aliasDevice = alias
        }
        
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <entrada>
                    \(params.userDataDTO.getUserDataWithChannelAndCompany)
                    <idioma>
                        <IDIOMA_ISO>\(serviceLanguage(BSANHeaderData.DEFAULT_LANGUAGE_ISO_SAN_ES))</IDIOMA_ISO>
                        <DIALECTO_ISO>\(BSANHeaderData.DEFAULT_DIALECT_ISO_SAN_ES)</DIALECTO_ISO>
                    </idioma>
                    <udid>\(params.deviceUDID)</udid>
                    <fechaRegistro>\(DateFormats.toString(date: Date(), output: .DDMMYYYY_HHmmssSSSSSS))</fechaRegistro>
                    <tokenPush>\(params.deviceToken)</tokenPush>
                    <aliasDispositivo>\(aliasDevice)</aliasDispositivo>
                    <idiomaDispositivo>\(params.deviceLanguage)</idiomaDispositivo>
                    <codDispositivo>\(params.deviceCode)</codDispositivo>
                    <modeloDispositivo>\(params.deviceModel)</modeloDispositivo>
                    <fabricaDispositivo>\(params.deviceBrand)</fabricaDispositivo>
                    <versionApp>\(params.appVersion)</versionApp>
                    <versionSDK>\(params.sdkVersion)</versionSDK>
                    <versionSO>\(params.soVersion)</versionSO>
                    <plataformaDispositivo>\(params.platform)</plataformaDispositivo>
                    <usuarioMod>\(params.modUser)</usuarioMod>
                    <desOperativa>\(params.operativeDes)</desOperativa>
                    <tokenPasos>\(params.stepToken)</tokenPasos>
                    <ticket>\(params.ticket)</ticket>
                    <codigoOtp>\(params.otpCode)</codigoOtp>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
