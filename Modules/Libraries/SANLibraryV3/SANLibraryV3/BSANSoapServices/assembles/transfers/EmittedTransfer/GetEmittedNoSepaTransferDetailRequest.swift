//

import Foundation

public class GetEmittedNoSepaTransferDetailRequest: BSANSoapRequest<GetEmittedNoSepaTransferDetailRequestParams, GetEmittedNoSepaTransferDetailHandler, GetEmittedNoSepaTransferDetailResponse, GetEmittedNoSepaTransferDetailParser> {
    
    static public var serviceName = "detalleEmitidaNoSepaLa"
    
    public override var serviceName: String {
        return GetEmittedNoSepaTransferDetailRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Consultas_transf_la/F_trasan_consultas_transf_la/ACTRASANConsultasTransfLa/"
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
                            <IDIOMA_ISO>\(serviceLanguage(params.languageISO))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialectISO)</DIALECTO_ISO>
                        </idioma>
                        \(params.userDataDTO.getUserDataWithChannelAndCompany)
                    </datosConexion>
                    <entrada>
                        <ordenServicio>
                            <CENTRO>
                                <EMPRESA>\(params.bankCode)</EMPRESA>
                                <CENTRO>\(params.branchCode)</CENTRO>
                            </CENTRO>
                            <PRODUCTO>\(params.product)</PRODUCTO>
                            <NUMERO_DE_ORDEN>\(params.contractNumber)</NUMERO_DE_ORDEN>
                        </ordenServicio>
                    </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
