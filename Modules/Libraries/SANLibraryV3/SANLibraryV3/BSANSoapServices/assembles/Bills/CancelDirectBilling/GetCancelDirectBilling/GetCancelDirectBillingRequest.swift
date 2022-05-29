//

import Foundation

public class GetCancelDirectBillingRequest: BSANSoapRequest<GetCancelDirectBillingRequestParams, GetCancelDirectBillingHandler, GetCancelDirectBillingResponse, GetCancelDirectBillingParser> {
    
    static public var serviceName = "consultaAnulaDomiciliacionLa"
    
    public override var serviceName: String {
        return GetCancelDirectBillingRequest.serviceName
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
                    <entrada>
                        <cuenta>
                            <CENTRO>
                                <EMPRESA>\(params.accountDTO.oldContract?.bankCode ?? "")</EMPRESA>
                                <CENTRO>\(params.accountDTO.oldContract?.branchCode ?? "")</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.accountDTO.oldContract?.product ?? "")</PRODUCTO>
                            <NUMERO_DE_CONTRATO>\(params.accountDTO.oldContract?.contractNumber ?? "")</NUMERO_DE_CONTRATO>
                        </cuenta>
                        <codProducto>\(params.billDTO.codProd)</codProducto>
                        <idCentro>
                            <EMPRESA>\(params.billDTO.company.empresa)</EMPRESA>
                            <CENTRO>\(params.centro ?? "")</CENTRO>
                        </idCentro>
                        <idEmpresa>\(params.billDTO.creditorCompanyId)</idEmpresa>
                        <numSor>\(params.billDTO.paymentOrderCode)</numSor>
                        <sentTras>R</sentTras>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
