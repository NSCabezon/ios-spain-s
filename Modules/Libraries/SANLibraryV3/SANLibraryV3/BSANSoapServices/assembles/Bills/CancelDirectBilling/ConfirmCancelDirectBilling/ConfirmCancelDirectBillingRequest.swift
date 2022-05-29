//

import Foundation

public class ConfirmCancelDirectBillingRequest: BSANSoapRequest<ConfirmCancelDirectBillingRequestParams, BSANSoapEmptyParser.Handler, BSANSoapEmptyResponse, BSANSoapEmptyParser> {
    
    static public var serviceName = "confirmaAnulaDomiciliacionLa"
    
    public override var serviceName: String {
        return ConfirmCancelDirectBillingRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/RECSAN/Cambiomasdomis_la/F_recsan_cambiomasdomis_la/ACRECSANCambioMasivo/v1"
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
                    <idioma>
                        <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                        <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                    </idioma>
                    \(params.userDataDTO.getClientChannelWithCompany())
                </datosConexion>
                <firma>\(getSignatureXmlFormatP(signatureDTO: params.signature))</firma>
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
                    <TIPAUTO>\(params.getCancelDirectBillingDTO.tipauto)</TIPAUTO>
                    <CDINAUT>\(params.getCancelDirectBillingDTO.cdinaut)</CDINAUT>
                    <DEUACR>DE</DEUACR>
                    <TIPMOTI>SEV</TIPMOTI>
                    <FECFIN>9999-12-31</FECFIN>
                    <AOBSERCC>ANULACION REALIZADA POR EL DEUDOR</AOBSERCC>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
