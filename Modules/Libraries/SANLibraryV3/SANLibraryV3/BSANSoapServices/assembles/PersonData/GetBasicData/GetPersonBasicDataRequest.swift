public class GetPersonBasicDataRequest: BSANSoapRequest<GetPersonBasicDataRequestParams, GetPersonBasicDataHandler, GetPersonBasicDataResponse, GetPersonBasicDataParser> {
    
    public static let SERVICE_NAME = "consultarDBasicos"
    
    public override var serviceName: String {
        return GetPersonBasicDataRequest.SERVICE_NAME
    }
    
    override var nameSpace: String {
        return "http://www.isban.es/webservices/BDPESP/Consdatospersexcdes_e/F_bdpesp_consultasexcedescr_e/internet/"
    }
    
    override var message: String {
        return "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" "
            + " xmlns:v1=\"\(nameSpace)\(facade)/v1\">"
            + "  <soapenv:Header>"
            + "    \(getSecurityHeader(params.token))"
            + "  </soapenv:Header>"
            + "  <soapenv:Body>"
            + "  <v1:\(serviceName) facade=\"\(facade)\">"
            
            + "  <entrada>"
            + "  <empresa>0049</empresa>"
            + "  <canal>\(params.userDataDTO.channelFrame ?? "")</canal>"
            
            + "  <lista>"
            
            + "  <registro>"
            + "  <persona>"
            
            + "  <TIPO_DE_PERSONA>\(params.userDataDTO.clientPersonType ?? "")</TIPO_DE_PERSONA>"
            + "  <CODIGO_DE_PERSONA>\(params.userDataDTO.clientPersonCode ?? "")</CODIGO_DE_PERSONA>"
            
            + "  </persona>"
            
            + "  <indicadorBasicos>\(params.basicDataIndicator)</indicadorBasicos>"
            + "  <indicadorDomicilios>\(params.addressIndicator)</indicadorDomicilios>"
            + "  <indicadorTelefonos>\(params.phoneIndicator)</indicadorTelefonos>"
            
            + "  </registro>"
            
            + "  </lista>"
            + "  </entrada>"
            
            + " </v1:\(serviceName)>"
            + " </soapenv:Body>"
            + " </soapenv:Envelope>"
    }
    
}
