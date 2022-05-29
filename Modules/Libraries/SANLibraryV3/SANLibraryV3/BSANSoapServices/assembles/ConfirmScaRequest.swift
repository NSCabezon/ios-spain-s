//

import Foundation

public class ConfirmScaRequest: BSANSoapRequest<ConfirmScaRequestParams, ConfirmScaHandler, ConfirmScaResponse, ConfirmScaParser> {
    
    static public var serviceName = "confirmarSCALa"
    
    public override var serviceName: String {
        return ConfirmScaRequest.serviceName
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
                        <tokenOTP>\(params.tokenOTP ?? "")</tokenOTP>
                        <ticket>\(params.ticketOTP ?? "")</ticket>
                        <claveOTP>\(params.codeOTP)</claveOTP>
                        <indOperativa>\(params.operativeIndicator.rawValue)</indOperativa>
                    </entrada>
                </new:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
