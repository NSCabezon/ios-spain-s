import CoreDomain

public class ValidateDeferredTransferRequest: BSANSoapRequest<ValidateDeferredTransferRequestParams, ValidateDeferredTransferHandler, ValidateDeferredTransferResponse, ValidateDeferredTransferParser> {
    
    private static let SERVICE_NAME = "validaDiferidasSepaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ValidateDeferredTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
        
        let amount = params.transferAmount
        
        let dateNextExecution: String
        
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
            "            <importe>" +
            "               <IMPORTE>\(AmountFormats.getValueForWS(value: amount.value))</IMPORTE>" +
            "               <DIVISA>\(amount.currency?.currencyName ?? "")</DIVISA>" +
            "            </importe>" +
            "            <cuentaIBANBeneficiario>" +
            "               <PAIS>\(params.iban.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.iban.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.iban.codBban30)</CODBBAN>" +
            "            </cuentaIBANBeneficiario>" +
            "           <nombreCompletoBeneficiario>\(params.beneficiary)</nombreCompletoBeneficiario> " +
            "           <indicadorResidenciaDestinatario>\(params.indicatorResidence)</indicadorResidenciaDestinatario>" +
            "           <concepto>\(params.concept ?? "")</concepto>" +
            "           <fechaProximaEjecucion>\(dateNextExecution)</fechaProximaEjecucion>" +
            "           <divisaCtoOrd>\(params.currency)</divisaCtoOrd>" +
            "           <iban>" +
            "               <PAIS>\(params.ibanOrigin.countryCode)</PAIS>" +
            "               <DIGITO_DE_CONTROL>\(params.ibanOrigin.checkDigits)</DIGITO_DE_CONTROL>" +
            "               <CODBBAN>\(params.ibanOrigin.codBban30)</CODBBAN>" +
            "           </iban>" +
            "        </entrada>" +
            "     </v1:\(serviceName)>" +
            "  </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ValidateDeferredTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let transferAmount: AmountDTO
    public let beneficiary: String
    public let iban: IBANDTO
    public let indicatorResidence: Bool
    public let concept: String?
    public let dateNextExecution: DateModel?
    public let currency: String
    public let ibanOrigin: IBANDTO
}

