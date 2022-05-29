import Foundation

public class GetUsualTransfersRequest: BSANSoapRequest<GetUsualTransfersRequestParams, GetUsualTransfersHandler, GetUsualTransfersResponse, GetUsualTransfersParser> {
    
    private static let SERVICE_NAME = "busquedaPayeeLa"
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/TRASAN/Benefinter_la/F_trasan_benefinter_la/"
    }
    
    public override var serviceName: String {
        return GetUsualTransfersRequest.SERVICE_NAME
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"" +
            "   xmlns:v1=\"\(nameSpace)\(facade)/v1\">" +
            "        <soapenv:Header>" +
            "    \(getSecurityHeader(params.token))" +
            "                </soapenv:Header>" +
            "        <soapenv:Body>" +
            "        <v1:\(serviceName) facade=\"\(facade)\">" +
            "           <datosConexion>" +
            "               \(params.userDataDTO.getUserDataWithMultiChannelAndCompany())" +
            "                <idioma>" +
            "                    <IDIOMA_ISO>\(serviceLanguage(params.language))</IDIOMA_ISO>" +
            "                    <DIALECTO_ISO>\(params.dialect)</DIALECTO_ISO>" +
            "                </idioma>" +
            "           </datosConexion>" +
            "           <filtro>" +
            "               <codEstado>01</codEstado>" +
            "           </filtro>" +
            "           \(params.pagination?.repositionXML.replace("paginacion", "datosPaginacion") ?? getEmptyPagination())" +
            "        </v1:\(serviceName)>" +
            "        </soapenv:Body>" +
            "        </soapenv:Envelope>"
    }
    
    private func getEmptyPagination() -> String {
        return "           <datosPaginacion>" +
            "               <memento/>" +
            "               <indicador/>" +
        "           </datosPaginacion>"
    }
}
