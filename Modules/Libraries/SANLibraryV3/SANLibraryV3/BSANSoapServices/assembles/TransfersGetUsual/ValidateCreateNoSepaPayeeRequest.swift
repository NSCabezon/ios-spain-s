//

import Foundation

public class ValidateCreateNoSepaPayeeRequest: BSANSoapRequest<ValidateCreateNoSepaPayeeRequestParams, ValidateCreateNoSepaPayeeHandler, ValidateCreateNoSepaPayeeResponse, ValidateCreateNoSepaPayeeParser> {
    
    static public var serviceName = "validaAltaPayeeNoSepaLa"
    
    public override var serviceName: String {
        return ValidateCreateNoSepaPayeeRequest.serviceName
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
                        <beneficiarioNoSepa>
                            <pais>\(params.noSepaPayeeDTO?.countryCode ?? "")</pais>
                            <nombrePais>\(params.noSepaPayeeDTO?.countryName ?? "")</nombrePais>
                            <localidad>\(params.noSepaPayeeDTO?.town ?? "")</localidad>
                            <domicilio>\(params.noSepaPayeeDTO?.address ?? "")</domicilio>
                        </beneficiarioNoSepa>
                        <bancoNoSepa>
                            <bic>\(params.noSepaPayeeDTO?.swiftCode ?? "")</bic>
                            <pais>\(params.noSepaPayeeDTO?.bankCountryCode ?? "")</pais>
                            <nombreBanco>\(params.noSepaPayeeDTO?.bankName ?? "")</nombreBanco>
                            <nombrePais>\(params.bankCountryName)</nombrePais>
                            <localidad>\(params.bankTown)</localidad>
                            <domicilio>\(params.bankAddress)</domicilio>
                        </bancoNoSepa>
                        <importe>
                            <IMPORTE>0.00</IMPORTE>
                            <DIVISA>\(params.newCurrencyDTO?.currencyName ?? "")</DIVISA>
                        </importe>
                        <cuentaBeneficiario>\(params.noSepaPayeeDTO?.paymentAccountDescription?.account34 ?? "")</cuentaBeneficiario>
                        <concepto></concepto>
                        <fechaProximaEjecucion></fechaProximaEjecucion>
                        <nombreBeneficiario>\(params.noSepaPayeeDTO?.name ?? "")</nombreBeneficiario>
                        <alias>\(params.newAlias)</alias>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
