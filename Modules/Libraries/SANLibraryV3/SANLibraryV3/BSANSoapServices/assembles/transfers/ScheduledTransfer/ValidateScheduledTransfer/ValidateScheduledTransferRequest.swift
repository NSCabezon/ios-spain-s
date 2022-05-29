import CoreDomain
import Foundation

public class ValidateScheduledTransferRequest: BSANSoapRequest<ValidateScheduledTransferRequestParams, ValidateScheduledTransferHandler, ValidateScheduledTransferResponse, ValidateScheduledTransferParser> {
    
    private static let SERVICE_NAME = "validaPeriodicasSepaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ValidateScheduledTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let amount = params.transferAmount
        
        let dateStartValidity: String
        let dateEndValidity: String
        let dateNextExecution: String
        
        if let date = params.dateStartValidity?.date {
            dateStartValidity = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateStartValidity = ""
        }
        
        if let date = params.dateEndValidity?.date {
            dateEndValidity = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateEndValidity = ""
        }
        
        if let date = params.dateNextExecution?.date {
            dateNextExecution = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateNextExecution = ""
        }
        
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "   <soapenv:Body>" +
            "      <v1:\(serviceName) facade=\"\(facade)\">" +
            "        <datosConexion>" +
            "            <idioma>" +
            "               <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "               <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "            </idioma>" +
            "                \(params.userDataDTO.getUserDataWithChannelAndCompanyAndMultiContract)" +
            "        </datosConexion>" +
            "        <entrada>" +
            "           <periodicidad>" +
            "               <dia>\(params.dateStartValidity?.day ?? "1")</dia>" +
            "               <mes>\(params.periodicalType.type)</mes>" +
            "               <tiempo>\(params.periodicalType.type)</tiempo> " +
            "           </periodicidad>" +
            "           <nombreCompletoBeneficiario>\(params.beneficiary)</nombreCompletoBeneficiario> " +
            "           <fechaInicioVigencia>\(dateStartValidity)</fechaInicioVigencia> " +
            "           <fechaFinVigencia>\(dateEndValidity)</fechaFinVigencia> " +
            "            <importe>" +
            "               <IMPORTE>\(AmountFormats.getValueForWS(value: amount.value))</IMPORTE>" +
            "               <DIVISA>\(amount.currency?.currencyName ?? "")</DIVISA>" +
            "            </importe>" +
            "            <indicadorTratamientoFechaEmis>" +
            "               <EMPRESA>\(params.company)</EMPRESA>" +
            "               <CODIGO_ALFANUM>\(params.scheduledDayType.type)</CODIGO_ALFANUM>" +
            "            </indicadorTratamientoFechaEmis>" +
            "            <indicadorPeriodicidad>" +
            "               <EMPRESA>\(params.company)</EMPRESA>" +
            "               <CODIGO_ALFANUM_3>\(params.periodicalType.rawValue)</CODIGO_ALFANUM_3> " +
            "            </indicadorPeriodicidad>" +
            "            <indicadorResidenciaDestinatario>\(params.indicatorResidence)</indicadorResidenciaDestinatario>" +
            "            <cuentaIBANBeneficiario>" +
            "               <PAIS>\(params.iban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.iban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.iban.codBban30)</CODBBAN>" +
            "            </cuentaIBANBeneficiario>" +
            "            <concepto>\(params.concept ?? "")</concepto>" +
            "            <fechaProximaEjecucion>\(dateNextExecution)</fechaProximaEjecucion>" +
            "            <divisaCtoOrd>\(params.currency)</divisaCtoOrd>" +
            "            <iban>" +
            "               <PAIS>\(params.ibanOrigin.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.ibanOrigin.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.ibanOrigin.codBban30)</CODBBAN>" +
            "            </iban>" +
            "            <empresaBenef>\(params.company)</empresaBenef>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ValidateScheduledTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let beneficiary: String
    public let dateStartValidity: DateModel?
    public let dateEndValidity: DateModel?
    public let transferAmount: AmountDTO
    public let company: String
    public let scheduledDayType: ScheduledDayDTO
    public let periodicalType: PeriodicalTypeTransferDTO
    public let indicatorResidence: Bool
    public let iban: IBANDTO
    public let concept: String?
    public let dateNextExecution: DateModel?
    public let currency: String
    public let ibanOrigin: IBANDTO
}
