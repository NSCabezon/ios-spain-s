//

import Foundation

public class ValidateScaRequest: BSANSoapRequest<ValidateScaRequestParams, ValidateScaHandler, ValidateScaResponse, ValidateScaParser> {
    
    static public var serviceName = "solicitarOTPSCALa"
    
    public override var serviceName: String {
        return ValidateScaRequest.serviceName
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
                        <indReenvio>\(params.forwardIndicator ? "S": "N")</indReenvio>
                        <indOperativa>\(params.operativeIndicator.rawValue)</indOperativa>
                        <forzarSMS>\(params.forceSMS ? "S": "")</forzarSMS>
                        <empresaAsociada>\(params.linkedCompany)</empresaAsociada>
                    </entrada>
                </new:\(serviceName)>
            </soapenv:Body>
        </soapenv:Envelope>
        """
    }
}
