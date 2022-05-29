import Foundation

public class ValidateRemoveSepaPayeeRequest: BSANSoapRequest<ValidateRemoveSepaPayeeRequestParams, ValidateRemoveSepaPayeeHandler, ValidateRemoveSepaPayeeResponse, ValidateRemoveSepaPayeeParser> {
    
    static public let serviceName = "validaBajaPayeeLa"
    
    public override var serviceName: String {
        return ValidateRemoveSepaPayeeRequest.serviceName
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
        \(params.userDataDTO.getUserDataWithMultiChannelAndCompany())"
        <idioma>"
        <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>"
        <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>"
        </idioma>"
        </datosConexion>
        <entrada>
        <codigoPayee>\(params.payeeCode)</codigoPayee>
        <tipoDestinatario>\(params.recipientType)</tipoDestinatario>
        <alias>\(params.alias)</alias>
        <tipoCuenta>\(params.accountType)</tipoCuenta>
        </entrada>
        </v1:\(serviceName)>
        </soapenv:Body>
        </soapenv:Envelope>
        """
    }    
}
