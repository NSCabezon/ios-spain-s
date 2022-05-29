//

import Foundation

public class CheckScaRequest: BSANSoapRequest<CheckScaRequestParams, CheckScaHandler, CheckScaResponse, CheckScaParser> {
    
    static public var serviceName = "comprobarSCALa"
    
    public override var serviceName: String {
        return CheckScaRequest.serviceName
    }
    
    override var nameSpace: String {
        return "http://new.webservice.namespace"
    }
    
    override var message: String {
        return """
        <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:new="\(nameSpace)">
            <soapenv:Header>
                \(getSecurityHeader(params.token))
            </soapenv:Header>
            <soapenv:Body>
                <new:\(serviceName) facade="\(facade)">
                    <entrada>
                        \(params.userDataDTO.getDataUserWithContractCmc)
                        <idioma>
                            <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>
                            <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>
                        </idioma>
                    </entrada>
                </new:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
