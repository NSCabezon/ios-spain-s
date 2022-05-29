import Foundation

public class ValidateCreateSepaPayeeRequest: BSANSoapRequest<ValidateCreateSepaPayeeRequestParams, ValidateCreateSepaPayeeHandler, ValidateCreateSepaPayeeResponse, ValidateCreateSepaPayeeParser> {
    
    static public let serviceName = "validaAltaPayeeSepaLa"
    
    public override var serviceName: String {
        return ValidateCreateSepaPayeeRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Benefinter_la/F_trasan_benefinter_la/ACTRANSANBenefInterLa/v1"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
        <soapenv:Header>
        \(getSecurityHeader(params.token))
        </soapenv:Header>
        <soapenv:Body>
        <v1:\(serviceName) facade="\(facade)">
        <datosConexion>
        \(params.userDataDTO.getUserDataWithMultiChannelAndCompany()) 
        <idioma>
        <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
        <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
        </idioma>"
        </datosConexion>
        <entrada>
        <iban>
        <PAIS>\(params.iban?.countryCode ?? "")</PAIS>
        <DIGITO_DE_CONTROL>\(params.iban?.checkDigits ?? "")</DIGITO_DE_CONTROL>
        <CODBBAN>\(params.iban?.codBban30 ?? "")</CODBBAN>
        </iban>
        <importe>
            <IMPORTE>0.00</IMPORTE>
            <DIVISA>EUR</DIVISA>
        </importe>
        <nombreBeneficiario>\(params.beneficiary)</nombreBeneficiario>
        <alias>\(params.alias)</alias>
        <tipoDestinatario>\(params.recipientType)</tipoDestinatario>
        <fechaOperacion>\(convert(date: params.operationDate))</fechaOperacion>
        <concepto></concepto>
        </entrada>
        </v1:\(serviceName)>
        </soapenv:Body>
        </soapenv:Envelope>
        """
    }
    
    private func convert(date: Date) -> String {
        return DateFormats.toString(date: date, output: DateFormats.TimeFormat.YYYYMMDD)
    }
}
