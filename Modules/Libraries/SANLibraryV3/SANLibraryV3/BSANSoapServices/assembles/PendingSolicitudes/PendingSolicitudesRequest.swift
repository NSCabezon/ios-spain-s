//

import Foundation

public class PendingSolicitudesRequest: BSANSoapRequest<PendingSolicitudesRequestParams, PendingSolicitudesHandler, PendingSolicitudesResponse, PendingSolicitudesParser> {
    
    static public var serviceName = "obtSolicitPendientesLa"
    
    public override var serviceName: String {
        return PendingSolicitudesRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BUZCO1/Gestionucp_la/F_buzco1_gestionucp_la/ACBUZCO1BuzonContratosWs/v1"
    }
    
    override var facade: String {
        return "ACBUZCO1BuzonContratosWs"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <v1:\(serviceName) facade="\(facade)">
                <entrada>
                    <idioma>
                     <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                     <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                    </idioma>
                   <empresa>\(params.userDataDTO.contract?.bankCode ?? "")</empresa>
                   <canal>\(params.userDataDTO.channelFrame ?? "")</canal>
                </entrada>
                </v1:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
