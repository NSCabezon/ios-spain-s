import Foundation

public class CheckMovementPdfRequest: BSANSoapRequest <CheckMovementPdfRequestParams, CheckMovementPdfHandler, CheckMovementPdfResponse, CheckMovementPdfParser> {
    
    public static let serviceName = "consultaPdfMovimientoLa"
    
    public override var serviceName: String {
        return CheckMovementPdfRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/CUENTA/Pdfmovimientola/F_cuenta_pdfmovimientola/"
    }
    
    override var message: String {
        let operationDateString: String
        if let operationDate = params.date {
            operationDateString = DateFormats.toString(date: operationDate, output: DateFormats.TimeFormat.YYYYMMDD)
        } else {
            operationDateString = ""
        }
        let returnString = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" " +
            " xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "   <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>" +
            "       <soapenv:Body>" +
            "           <v1:" + serviceName + " facade=\"" + facade + "\">" +
            "               <datosConexion>" +
            "                   <idioma>" +
            "                       <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>" +
            "                       <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>" +
            "                   </idioma>" +
            "                   \(params.userDataDTO.getUserDataWithChannel().replace("contratoMulticanal", "contrato"))" +
            "                   <empresa>\(params.company)</empresa>" +
            "               </datosConexion>" +
            "               <entrada>" +
            "                   <conceptoSaldo>000</conceptoSaldo>" +
            "                   <monedaMovimiento>\(params.currency)</monedaMovimiento>" +
            "                   <fechaMovimiento>\(operationDateString)</fechaMovimiento>" +
            "                   <diaMovimiento>\(params.transactionDay)</diaMovimiento>" +
            "                   <contratoMovimiento>" +
            "                       <PAIS>\(params.iban?.countryCode ?? "")</PAIS>" +
            "                       <DIGITO_DE_CONTROL>\(params.iban?.checkDigits ?? "")</DIGITO_DE_CONTROL>" +
            "                       <CODBBAN>\(params.iban?.codBban30 ?? "")</CODBBAN>" +
            "                   </contratoMovimiento>" +
            "               </entrada>" +
            "       </v1:\(serviceName)>" +
            "   </soapenv:Body>" +
        "</soapenv:Envelope>"
        return returnString
    }
}
