public class ConfirmChangeDirectDebitRequest: BSANSoapRequest<ConfirmChangeDirectDebitRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static public var serviceName = "confirmaCambioIndividualSepaLa"
    
    public override var serviceName: String {
        return ConfirmChangeDirectDebitRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Cambiomasdomis_la/F_recsan_cambiomasdomis_la/ACRECSANCambioMasivo/v1"
    }
    
    override var message: String {
        let signatureString: String
        if let signature = params.signature.signatureDTO {
            signatureString = getSignatureXmlFormatP(signatureDTO: signature)
        } else {
            signatureString = ""
        }
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <datosConexion>
                    <idioma>
                        <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                        <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                    </idioma>
                    \(params.userDataDTO.getClientChannelWithCompany())
                </datosConexion>
                <firma>\(signatureString)</firma>
                <entrada>
                    <cuenta>
                        <CENTRO>
                            <EMPRESA>\(params.accountDTO.contract?.bankCode ?? "")</EMPRESA>
                            <CENTRO>\(params.accountDTO.contract?.branchCode ?? "")</CENTRO>
                        </CENTRO>
                        <PRODUCTO>\(params.accountDTO.contract?.product ?? "")</PRODUCTO>
                        <NUMERO_DE_CONTRATO>\(params.accountDTO.contract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                    </cuenta>
                    <IDEMPR>\(params.billDTO.creditorCompanyId)</IDEMPR>
                    <TIPAUTO>\(params.billDTO.tipauto)</TIPAUTO>
                    <CDINAUT>\(params.billDTO.cdinaut)</CDINAUT>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
