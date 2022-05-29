import Foundation

public class ConfirmModifyLimitCardOtpRequest: BSANSoapRequest<ConfirmModifyLimitCardOtpRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    public static let SERVICE_NAME = "confirmarModifcarLimiteTjtaOTP_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/SWENDI/Enviodinero_la/F_swendi_enviodinero_la/internet/"
    }
    
    public override var serviceName: String {
        return ConfirmModifyLimitCardOtpRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let dateAuthorizationDay: String
        if let date = params.cardSuperSpeedDTO.dateAuthorizationDay {
            dateAuthorizationDay = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateAuthorizationDay = ""
        }
        
        let msg: String = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "  xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:\(serviceName) facade=\"\(facade)\">" +
            "               <entrada>" +
            "                   <token>\(params.otpValidationDTO.magicPhrase ?? "")</token>" +
            "                   <ticket>\(params.otpValidationDTO.ticket ?? "")</ticket>" +
            "                   <codigoOtp>\(params.otpCode ?? "")</codigoOtp>" +
            "                   <pan>\(params.cardNumber)</pan>" +
            "                   <impLimDiarioCajero>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.atmLimitDailyAmount.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.atmLimitDailyAmount.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDiarioCajero>" +
            "                   <impLimCredTarjeta>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.limitCreditCard?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.limitCreditCard?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimCredTarjeta>" +
            "                   <impLimitempCredTarjeta>" +
            "                       <IMPORTE>0.00</IMPORTE>" +
            "                       <DIVISA>EUR</DIVISA>" +
            "                   </impLimitempCredTarjeta>" +
            "                   <fechInicTempCred>\(params.temporaryLimitCreditStart)</fechInicTempCred>" +
            "                   <fechFinTempCred>\(params.temporaryLimitCreditEnd)</fechFinTempCred>" +
            "                   <impLimCredMensual>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.limitMonthlyCredit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.limitMonthlyCredit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimCredMensual>" +
            "                   <impLImitempCredMensual>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.temporaryLimitMonthlyCredit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.temporaryLimitMonthlyCredit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLImitempCredMensual>" +
            "                   <fechInicTempCredMen>\(params.temporaryLimitCreditMonthStart)</fechInicTempCredMen>" +
            "                   <fechFinTempCredMen>\(params.temporaryLimitCreditMonthEnd)</fechFinTempCredMen>" +
            "                   <impLimDebMensual>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.limitMonthlyDebit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.limitMonthlyDebit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDebMensual>" +
            "                   <fechInicTempDebMen>\(params.temporaryLimitDebitMonthStart)</fechInicTempDebMen>" +
            "                   <fechFinTempDebMen>\(params.temporaryLimitDebitMonthEnd)</fechFinTempDebMen>" +
            "                   <fechaAutorizacionDiaria>\(dateAuthorizationDay)</fechaAutorizacionDiaria>" +
            "                   <impLimCredDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.limitDailyCredit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.limitDailyCredit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimCredDiario>" +
            "                   <impLimitempCredDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.temporaryLimitDailyCredit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.temporaryLimitDailyCredit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimitempCredDiario>" +
            "                   <fechInicTempCredDia>\(params.temporaryLimitCreditDayStart)</fechInicTempCredDia>" +
            "                   <fechFinTempCredDia>\(params.temporaryLimitCreditDayEnd)</fechFinTempCredDia>" +
            "                   <impLimDebDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.debitLimitDailyAmount.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.debitLimitDailyAmount.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDebDiario>" +
            "                   <impLimitempDebDiario>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.temporaryLimitDailyDebit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.temporaryLimitDailyDebit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimitempDebDiario>" +
            "                   <fechInicTempDebDia>\(params.temporaryLimitDebitDayStart)</fechInicTempDebDia>" +
            "                   <fechFinTempDebDia>\(params.temporaryLimitDebitDayEnd)</fechFinTempDebDia>" +
            "                   <numLimOperDiaCaj>\(params.cardSuperSpeedDTO.numberLimitOperationsDayCashier ?? "")</numLimOperDiaCaj>" +
            "                   <numLimOperMes>\(params.cardSuperSpeedDTO.numberLimitOperationsMonth ?? "")</numLimOperMes>" +
            "                   <numLimOperDia>\(params.cardSuperSpeedDTO.numberLimitOperationsDay ?? "")</numLimOperDia>" +
            "                   <marcaTiempo>\(params.cardSuperSpeedDTO.timeMark ?? "")</marcaTiempo>" +
            "                   <impLimitempDebMensual>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.temporaryLimitMonthlyDebit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.temporaryLimitMonthlyDebit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimitempDebMensual>" +
            "                   <impLimDiarioCajeroAntiguo>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.dailyCashierLimit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.dailyCashierLimit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDiarioCajeroAntiguo>" +
            "                   <impLimCredDiarioAntiguo>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.limitDailyCredit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.limitDailyCredit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimCredDiarioAntiguo>" +
            "                   <impLimDebDiarioAntiguo>" +
            "                       <IMPORTE>+\(AmountFormats.getValueForWS(value: params.cardSuperSpeedDTO.dailyDebitLimit?.value ?? 0))</IMPORTE>" +
            "                       <DIVISA>\(params.cardSuperSpeedDTO.dailyDebitLimit?.currency?.currencyName ?? "")</DIVISA>" +
            "                   </impLimDebDiarioAntiguo>" +
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

public struct ConfirmModifyLimitCardOtpRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let languageISO: String
    public let dialectISO: String
    public let cardNumber: String
    public let otpCode: String?
    public let linkedCompany: String
    public let debitLimitDailyAmount: AmountDTO
    public let atmLimitDailyAmount: AmountDTO
    public let otpValidationDTO: OTPValidationDTO
    public let cardSuperSpeedDTO: CardSuperSpeedDTO
    public let temporaryLimitCreditStart: String
    public let temporaryLimitCreditEnd: String
    public let temporaryLimitCreditMonthStart: String
    public let temporaryLimitCreditMonthEnd: String
    public let temporaryLimitCreditDayStart: String
    public let temporaryLimitCreditDayEnd: String
    public let temporaryLimitDebitMonthStart: String
    public let temporaryLimitDebitMonthEnd: String
    public var temporaryLimitDebitDayStart: String
    public var temporaryLimitDebitDayEnd: String
}
