import CoreDomain
import Foundation

public class ConfirmScheduledTransferRequest: BSANSoapRequest<ConfirmScheduledTransferRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    private static let SERVICE_NAME = "confirmaPeriodicasSepaLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Periodicas_la/F_trasan_periodicas_la/"
    }
    
    public override var serviceName: String {
        return ConfirmScheduledTransferRequest.SERVICE_NAME
    }
    
    override var message: String {
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
            dateEndValidity = "9999-12-31"
        }
        
        if let date = params.dateNextExecution?.date {
            dateNextExecution = DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            dateNextExecution = dateStartValidity
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
            "           <fechaInicioVigencia>\(dateStartValidity)</fechaInicioVigencia> " +
            "           <fechaFinVigencia>\(dateEndValidity)</fechaFinVigencia> " +
            "           <indicadorTratamientoFechaEmis>" +
            "               <EMPRESA>\(params.actuanteCompany)</EMPRESA>" +
            "               <CODIGO_ALFANUM>\(params.scheduledDayType.type)</CODIGO_ALFANUM>" +
            "           </indicadorTratamientoFechaEmis>" +
            "           <indicadorPeriodicidad>" +
            "               <EMPRESA>\(params.actuanteCompany)</EMPRESA>" +
            "               <CODIGO_ALFANUM_3>\(params.periodicalType.type)</CODIGO_ALFANUM_3> " +
            "           </indicadorPeriodicidad>" +
            "            <indicadorResidenciaDestinatario>\(params.indicatorResidence ? "S" : "N")</indicadorResidenciaDestinatario>" +
            "            <concepto>\(params.concept ?? "")</concepto>" +
            "            <fechaProximaEjecucion>\(dateNextExecution)</fechaProximaEjecucion>" +
            "            <divisaCtoOrd>\(params.currency)</divisaCtoOrd>" +
            "            <empresaBenef>\(params.nameBankIbanBeneficiary)</empresaBenef>" +
            "           <codigoActuante>" +
            "             <TIPO_DE_ACTUANTE>" +
            "                 <EMPRESA>\(params.actuanteCompany)</EMPRESA>" +
            "                 <COD_TIPO_DE_ACTUANTE>\(params.actuanteCode)</COD_TIPO_DE_ACTUANTE>" +
            "             </TIPO_DE_ACTUANTE>" +
            "             <NUMERO_DE_ACTUANTE>\(params.actuanteNumber)</NUMERO_DE_ACTUANTE>" +
            "           </codigoActuante>" +
            "           <indicadorAltaPayee>\(params.saveAsUsual ? "S" : "N")</indicadorAltaPayee>" +
            "           <alias>\(params.saveAsUsualAlias.uppercased())</alias>" +
            "           <token>\(params.dataToken)</token>" +
            "           <ticket>\(params.ticketOTP)</ticket>" +
            "           <codigoOtp>\(params.codeOTP)</codigoOtp>" +
            "           <nombreCompletoBeneficiario>\(params.beneficiary)</nombreCompletoBeneficiario>" +
            "         </entrada>" +
            "        </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
    }
}

public struct ConfirmScheduledTransferRequestParams {
    public let token: String
    public let userDataDTO: UserDataDTO
    public let dialectISO: String
    public let languageISO: String
    public let beneficiary: String
    
    public let dateStartValidity: DateModel?
    public let dateEndValidity: DateModel?
    public let company: String
    public let scheduledDayType: ScheduledDayDTO
    public let periodicalType: PeriodicalTypeTransferDTO
    public let indicatorResidence: Bool
    
    public let concept: String?
    public let dateNextExecution: DateModel?
    public let currency: String
    
    public let nameBankIbanBeneficiary: String
    public let actuanteCompany: String
    public let actuanteCode: String
    public let actuanteNumber: String
    public let saveAsUsual: Bool
    public let saveAsUsualAlias: String
    public let dataToken: String
    public let ticketOTP: String
    public let codeOTP: String
}
