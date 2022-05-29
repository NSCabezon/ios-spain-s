//

import Foundation

public class ValidateUpdateSepaPayeeRequest: BSANSoapRequest<ValidateUpdateSepaPayeeRequestParams, ValidateUpdateSepaPayeeHandler, ValidateUpdateSepaPayeeResponse, ValidateUpdateSepaPayeeParser> {
    
    static public var serviceName = "validaModifPayeeSepaLa"
    
    public override var serviceName: String {
        return ValidateUpdateSepaPayeeRequest.serviceName
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
                        <iban>
                            <PAIS>\(params.newIban?.countryCode ?? "")</PAIS>
                            <DIGITO_DE_CONTROL>\(params.newIban?.checkDigits ?? "")</DIGITO_DE_CONTROL>
                            <CODBBAN>\(params.newIban?.codBban30 ?? "")</CODBBAN>
                        </iban>
                        <nombreBeneficiario>\(params.newBeneficiaryBAOName ?? "")</nombreBeneficiario>
                        <alias>\(params.payeeDTO.beneficiary ?? "")</alias>
                        <tipoDestinatario>\(params.payeeDTO.recipientType ?? "")</tipoDestinatario>
                        <moneda>\(params.newCurrencyDTO?.currencyName ?? "")</moneda>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
