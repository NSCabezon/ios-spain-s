import Foundation

public class ValidateModifyLimitCardOtpRequest: BSANSoapRequest<ValidateModifyLimitCardOtpRequestParams, ValidateModifyLimitCardOtpHandler, ValidateModifyLimitCardOtpResponse, ValidateModifyLimitCardOtpParser> {
    
    public static let SERVICE_NAME = "validarModifcarLimiteTarjetaOTP_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SWENDI/Enviodinero_la/F_swendi_enviodinero_la/internet/"
    }
    
    public override var serviceName: String {
        return ValidateModifyLimitCardOtpRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let signature: String
        if let signatureDTO = params.signatureWithToken.signatureDTO {
            signature = getSignatureXmlFormatP(signatureDTO: signatureDTO)
        } else {
            signature = ""
        }
        
        let msg: String = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <entrada>" +
            "                   <token>\(params.signatureWithToken.magicPhrase ?? "")</token>" +
            "                   <numeroTarjeta>\(params.cardNumber)</numeroTarjeta>" +
            "                   <impLimDebDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.debitLimitDailyAmount.value))</IMPORTE>" +
            "                       <DIVISA>\(params.debitLimitDailyAmount.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDebDiario>" +
            "                   <impLimDiarioCajero>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.atmLimitDailyAmount.value))</IMPORTE>" +
            "                       <DIVISA>\(params.atmLimitDailyAmount.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDiarioCajero>" +
            "                   <impLimCredDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.creditLimitDailyAmount.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.creditLimitDailyAmount.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimCredDiario>" +
            "               <datosFirma>\(signature)</datosFirma>" +
            "               </entrada>" +
            "               <datosConexion>\(params.userDataDTO.datosUsuario)</datosConexion>" +
            "               <datosCabecera>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   <empresaAsociada>\(params.linkedCompany)</empresaAsociada>" +
            "               </datosCabecera>" +
            "           </v1:\(serviceName)>" +
            "       </soapenv:Body>" +
            "   </soapenv:Envelope>"
        
        return msg
    }
    
}

public struct ValidateModifyLimitCardOtpRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let cardNumber: String
    public let linkedCompany: String
    public let signatureWithToken: SignatureWithTokenDTO
    public let debitLimitDailyAmount: AmountDTO
    public let atmLimitDailyAmount: AmountDTO
    public let creditLimitDailyAmount: AmountDTO
}

