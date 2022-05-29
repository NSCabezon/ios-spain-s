import Foundation

public class GetCardSuperSpeedRequest: BSANSoapRequest <GetCardSuperSpeedRequestParams, GetCardSuperSpeedHandler, GetCardSuperSpeedResponse, GetCardSuperSpeedParser> {
    
    public static let SERVICE_NAME = "consMasInfWallTjtsClient_LA"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TARSAN/Consultaimagen_la/F_tarsan_consultaimagen_la/internet/"
    }
    
    public override var serviceName: String {
        return GetCardSuperSpeedRequest.SERVICE_NAME
    }
    
    override var message: String {
        let output = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\""
            + "        xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "        <soapenv:Header>\(getSecurityHeader(params.token))</soapenv:Header>"
            + "        <soapenv:Body>"
            + "        <v1:\(serviceName) facade=\"\(facade)\">"
            + "         <entrada>"
            + "             <selectPag>\(params.pagination != nil ? "R" : "L")</selectPag>"
            // Wizink indicator must be from now on always N.
            + "             <indicadorWizink>N</indicadorWizink>"
            + "         </entrada>"
            + XMLHelper.getHeaderData(language: serviceLanguage(params.languageISO), dialect: params.dialectISO, linkedCompany: params.linkedCompany)
            + "         <datosConexion>\(params.userDataDTO.datosUsuarioWithEmpresa)</datosConexion>"
            + "\(params.pagination?.repositionXML ?? emptyRepos())"
            + "      </v1:consMasInfWallTjtsClient_LA>"
            + "   </soapenv:Body>"
            + "</soapenv:Envelope>"
        
        return output
    }
    
    private func emptyRepos() -> String {
        return  "   <repos>" +
            "      <numeroContrato>" +
            "         <CENTRO>" +
            "             <EMPRESA></EMPRESA>" +
            "             <CENTRO></CENTRO>" +
            "         </CENTRO>" +
            "         <PRODUCTO></PRODUCTO>" +
            "         <NUMERO_DE_CONTRATO></NUMERO_DE_CONTRATO>" +
            "      </numeroContrato>" +
            "      <codigoAplicacion></codigoAplicacion>" +
            "      <calidadParticipacion></calidadParticipacion>" +
            "      <numeroBeneficiario></numeroBeneficiario>" +
            "      <finLista></finLista>" +
            "    </repos>"
    }
}
